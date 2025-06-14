# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "aws_profile" {
  description = "The AWS profile to use for authentication"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment (used for resource naming)"
  type        = string
} 