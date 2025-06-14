# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "aws_profile" {
  description = "The profile name that you have configured in the file .aws/credentials"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "The AWS Region in which you want to deploy the resources"
  type        = string
  default     = "us-west-1"
}

variable "environment_name" {
  description = "The name of your environment"
  type        = string
  default     = "a37-demo-stack"

  validation {
    condition     = length(var.environment_name) < 23
    error_message = "Due the this variable is used for concatenation of names of other resources, the value must have less than 23 characters."
  }
}

variable "github_token" {
  description = "Personal access token from Github"
  type        = string
  sensitive   = true
}

variable "port_app_server" {
  description = "The port used by your server application"
  type        = number
  default     = 3001
}

variable "port_app_client" {
  description = "The port used by your client application"
  type        = number
  default     = 80
}

variable "buildspec_path" {
  description = "The location of the buildspec file"
  type        = string
  default     = "./Infrastructure/Templates/buildspec.yml"
}

variable "buildspec_path_eks" {
  description = "The location of the EKS buildspec file"
  type        = string
  default     = "./Infrastructure/Templates/buildspec-eks.yml"
}

variable "folder_path_server" {
  description = "The location of the server files"
  type        = string
  default     = "./server/."
}

variable "folder_path_client" {
  description = "The location of the client files"
  type        = string
  default     = "./client/."
}

variable "container_name" {
  description = "The name of the container of each service"
  type        = map(string)
  default = {
    server = "Container-server"
    client = "Container-client"
  }
}

variable "iam_role_name" {
  description = "The name of the IAM Role for each service"
  type        = map(string)
  default = {
    devops                = "DevOps-Role"
    ecs                   = "ECS-task-excecution-Role"
    ecs_task_role         = "ECS-task-Role"
    codedeploy            = "CodeDeploy-Role"
    eks_service_account   = "EKS-service-account-Role"
  }
}

variable "repository_owner" {
  description = "The name of the owner of the Github repository"
  type        = string
  default     = "a37ai"
}

variable "repository_name" {
  description = "The name of the Github repository"
  type        = string
  default     = "test-stack"
}

variable "repository_branch" {
  description = "The name of branch the Github repository, which is going to trigger a new CodePipeline excecution"
  type        = string
  default     = "main"
}

# EKS-specific variables
variable "kubernetes_version" {
  description = "The Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_capacity" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "eks_max_capacity" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 4
}

variable "eks_min_capacity" {
  description = "Minimum number of nodes in the EKS node group"  
  type        = number
  default     = 1
}

variable "service_account_name" {
  description = "The name of the Kubernetes service account"
  type        = string
  default     = "app-service-account"
}