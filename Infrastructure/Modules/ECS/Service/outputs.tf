# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}