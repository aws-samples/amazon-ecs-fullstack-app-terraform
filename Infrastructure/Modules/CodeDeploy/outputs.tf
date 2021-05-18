# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.main.deployment_group_name
}

output "deployment_group_arn" {
  value = aws_codedeploy_deployment_group.main.arn
}

output "application_name" {
  value = aws_codedeploy_deployment_group.main.app_name
}

output "application_arn" {
  value = aws_codedeploy_app.main.arn
}