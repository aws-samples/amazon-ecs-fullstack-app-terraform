# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

/*===========================
    Terraform State Backend
    Infrastructure Bootstrap
============================*/

# Provider configuration
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# Random ID for unique naming
resource "random_id" "state_bucket_suffix" {
  byte_length = 4
}

# S3 Bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-state-${var.environment_name}-${random_id.state_bucket_suffix.hex}"
  force_destroy = false

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment_name
    Purpose     = "terraform-state-storage"
  }
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state_pab" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock-${var.environment_name}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment_name
    Purpose     = "terraform-state-locking"
  }
} 