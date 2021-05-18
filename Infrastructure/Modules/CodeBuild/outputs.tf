# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "project_id" {
  value = aws_codebuild_project.aws_codebuild.id
}

output "project_arn" {
  value = aws_codebuild_project.aws_codebuild.arn
}