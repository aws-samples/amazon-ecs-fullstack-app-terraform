# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS node group"
  type        = list(string)
}

variable "node_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_capacity" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 4
}

variable "min_capacity" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
} 