# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn_task_definition" {
  value = aws_ecs_task_definition.ecs_task_definition.arn
}

output "task_definition_family" {
  value = aws_ecs_task_definition.ecs_task_definition.family
}