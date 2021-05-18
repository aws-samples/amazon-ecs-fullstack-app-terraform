# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.ecr_repository.arn
}