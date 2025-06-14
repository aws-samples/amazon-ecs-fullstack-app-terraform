# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks_cluster.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_cluster.eks_cluster_endpoint
}

output "codepipeline_url" {
  description = "CodePipeline URL"
  value       = "https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${module.codepipeline.codepipeline_name}/view"
}

output "ecr_repository_server_url" {
  description = "ECR Repository URL for server"
  value       = module.ecr_server.ecr_repository_url
}

output "ecr_repository_client_url" {
  description = "ECR Repository URL for client"
  value       = module.ecr_client.ecr_repository_url
}

# Note: Application URLs will be available after deployment via kubectl get ingress