# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state storage"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "backend_configuration" {
  description = "Backend configuration block to add to your main Terraform configuration"
  value = <<EOF
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.terraform_state.bucket}"
    key            = "terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${aws_dynamodb_table.terraform_state_lock.name}"
    encrypt        = true
  }
}
EOF
} 