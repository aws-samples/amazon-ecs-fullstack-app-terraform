# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

/*=========================================
      AWS Elastic Container Repository
==========================================*/

resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
}