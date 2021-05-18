# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn_role" {
  value = (var.create_ecs_role == true
    ? (length(aws_iam_role.ecs_task_excecution_role) > 0 ? aws_iam_role.ecs_task_excecution_role[0].arn : "")
  : (length(aws_iam_role.devops_role) > 0 ? aws_iam_role.devops_role[0].arn : ""))
}

output "name_role" {
  value = (var.create_ecs_role == true
    ? (length(aws_iam_role.ecs_task_excecution_role) > 0 ? aws_iam_role.ecs_task_excecution_role[0].name : "")
  : (length(aws_iam_role.devops_role) > 0 ? aws_iam_role.devops_role[0].name : ""))
}

output "arn_role_codedeploy" {
  value = (var.create_codedeploy_role == true
    ? (length(aws_iam_role.codedeploy_role) > 0 ? aws_iam_role.codedeploy_role[0].arn : "")
  : "")
}

output "arn_role_ecs_task_role" {
  value = (var.create_ecs_role == true
    ? (length(aws_iam_role.ecs_task_role) > 0 ? aws_iam_role.ecs_task_role[0].arn : "")
  : "")
}