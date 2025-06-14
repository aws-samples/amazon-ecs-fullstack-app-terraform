# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Backend configuration for Terraform state storage with DynamoDB locking
terraform {
  backend "s3" {
    bucket         = "terraform-state-demo-12db66cf"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-state-lock-demo"
    encrypt        = true
  }
} 