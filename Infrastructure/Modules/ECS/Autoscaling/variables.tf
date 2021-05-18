# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "min_capacity" {
  description = "The minimal number of ECS tasks to run"
  type        = number
}

variable "max_capacity" {
  description = "The maximal number of ECS tasks to run"
  type        = number
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "name" {
  description = "The name for the ECS service"
  type        = string
}