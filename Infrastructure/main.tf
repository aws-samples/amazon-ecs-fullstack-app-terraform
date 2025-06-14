# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

/*===========================
          Root file - EKS Version
============================*/

# ------- Providers -------
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# ------- Random numbers intended to be used as unique identifiers for resources -------
resource "random_id" "RANDOM_ID" {
  byte_length = "2"
}

# ------- Account ID -------
data "aws_caller_identity" "id_current_account" {}

# ------- Networking -------
module "networking" {
  source = "./Modules/Networking"
  cidr   = ["10.120.0.0/16"]
  name   = var.environment_name
}

# ------- Creating Security Group for ALB -------
module "security_group_alb" {
  source              = "./Modules/SecurityGroup"
  name                = "alb-${var.environment_name}"
  description         = "Controls access to the ALB for EKS services"
  vpc_id              = module.networking.aws_vpc
  cidr_blocks_ingress = ["0.0.0.0/0"]
  ingress_port        = 80
}

# ------- EKS Cluster -------
module "eks_cluster" {
  source             = "./Modules/EKS/Cluster"
  name               = var.environment_name
  subnet_ids         = concat(module.networking.public_subnets, module.networking.private_subnets_server, module.networking.private_subnets_client)
  private_subnet_ids = concat(module.networking.private_subnets_server, module.networking.private_subnets_client)
  kubernetes_version = var.kubernetes_version
  node_instance_types = var.eks_node_instance_types
  desired_capacity   = var.eks_desired_capacity
  max_capacity       = var.eks_max_capacity
  min_capacity       = var.eks_min_capacity
}

# ------- IAM Role for EKS Service Account (IRSA) - Created directly -------
resource "aws_iam_role" "eks_service_account_role" {
  name = var.iam_role_name["eks_service_account"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = module.eks_cluster.eks_cluster_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks_cluster.eks_cluster_endpoint, "https://", "")}:sub": "system:serviceaccount:default:${var.service_account_name}"
            "${replace(module.eks_cluster.eks_cluster_endpoint, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eks_service_account_policy" {
  name = "eks-service-account-policy"
  role = aws_iam_role.eks_service_account_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = module.dynamodb_table.dynamodb_table_arn
      }
    ]
  })
}

# ------- Creating server ECR Repository to store Docker Images -------
module "ecr_server" {
  source = "./Modules/ECR"
  name   = "repo-server"
}

# ------- Creating client ECR Repository to store Docker Images -------
module "ecr_client" {
  source = "./Modules/ECR"
  name   = "repo-client"
}

# ------- CodePipeline -------

# ------- Creating Bucket to store CodePipeline artifacts -------
module "s3_codepipeline" {
  source      = "./Modules/S3"
  bucket_name = "codepipeline-${var.aws_region}-${random_id.RANDOM_ID.hex}"
}

# ------- Creating IAM roles used during the pipeline execution -------
module "devops_role" {
  source             = "./Modules/IAM"
  create_devops_role = true
  name               = var.iam_role_name["devops"]
}

# ------- Creating an IAM Policy for role ------- 
module "policy_devops_role" {
  source                = "./Modules/IAM"
  name                  = "devops-${var.environment_name}"
  create_policy         = true
  attach_to             = module.devops_role.name_role
  create_devops_policy  = true
  ecr_repositories      = [module.ecr_server.ecr_repository_arn, module.ecr_client.ecr_repository_arn]
  code_build_projects   = [module.codebuild_client.project_arn, module.codebuild_server.project_arn]
}

# ------- Add EKS permissions to devops role -------
resource "aws_iam_role_policy" "devops_eks_policy" {
  name = "devops-eks-policy"
  role = module.devops_role.name_role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups"
        ]
        Resource = module.eks_cluster.eks_cluster_arn
      }
    ]
  })
}

# ------- Creating a SNS topic -------
module "sns" {
  source   = "./Modules/SNS"
  sns_name = "sns-${var.environment_name}"
}

# ------- Creating the server CodeBuild project -------
module "codebuild_server" {
  source                 = "./Modules/CodeBuild"
  name                   = "codebuild-${var.environment_name}-server"
  iam_role               = module.devops_role.arn_role
  region                 = var.aws_region
  account_id             = data.aws_caller_identity.id_current_account.account_id
  ecr_repo_url           = module.ecr_server.ecr_repository_url
  folder_path            = var.folder_path_server
  buildspec_path         = var.buildspec_path_eks
  task_definition_family = "${var.environment_name}-server" # Required by existing module
  container_name         = var.container_name["server"]
  service_port           = var.port_app_server
  ecs_role               = var.iam_role_name["ecs"] # Required by existing module
  ecs_task_role          = var.iam_role_name["ecs_task_role"] # Required by existing module
  dynamodb_table_name    = module.dynamodb_table.dynamodb_table_name
}

# ------- Creating the client CodeBuild project -------
module "codebuild_client" {
  source                 = "./Modules/CodeBuild"
  name                   = "codebuild-${var.environment_name}-client"
  iam_role               = module.devops_role.arn_role
  region                 = var.aws_region
  account_id             = data.aws_caller_identity.id_current_account.account_id
  ecr_repo_url           = module.ecr_client.ecr_repository_url
  folder_path            = var.folder_path_client
  buildspec_path         = var.buildspec_path_eks
  task_definition_family = "${var.environment_name}-client" # Required by existing module
  container_name         = var.container_name["client"]
  service_port           = var.port_app_client
  ecs_role               = var.iam_role_name["ecs"] # Required by existing module
  server_alb_url         = "http://${var.environment_name}-server-service.default.svc.cluster.local"
}

# ------- Creating CodePipeline -------
module "codepipeline" {
  source                   = "./Modules/CodePipeline"
  name                     = "pipeline-${var.environment_name}"
  pipe_role                = module.devops_role.arn_role
  s3_bucket                = module.s3_codepipeline.s3_bucket_id
  github_token             = var.github_token
  repo_owner               = var.repository_owner
  repo_name                = var.repository_name
  branch                   = var.repository_branch
  codebuild_project_server = module.codebuild_server.project_id
  codebuild_project_client = module.codebuild_client.project_id
  # Required by existing module - using dummy values since we're not using CodeDeploy
  app_name_server          = "dummy-server"
  app_name_client          = "dummy-client"
  deployment_group_server  = "dummy-server-dg"
  deployment_group_client  = "dummy-client-dg"

  depends_on = [module.policy_devops_role]
}

# ------- Creating Bucket to store assets accessed by the Back-end -------
module "s3_assets" {
  source      = "./Modules/S3"
  bucket_name = "assets-${var.aws_region}-${random_id.RANDOM_ID.hex}"
}

# ------- Creating DynamoDB table used by the Back-end -------
module "dynamodb_table" {
  source = "./Modules/Dynamodb"
  name   = "assets-table-${var.environment_name}"
}