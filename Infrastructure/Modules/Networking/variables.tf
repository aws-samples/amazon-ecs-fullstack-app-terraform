# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "name" {
  description = "Provided name used for name concatenation of resources"
  type        = string
}

variable "cidr" {
  description = "CIDR block"
  type        = list(any)
}

variable "subnets_number" {
  description = "Number of subnets to create (independent from type)"
  default     = 2
}