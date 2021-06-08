# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

/*=============================
        AWS ECS Cluster
===============================*/

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "Cluster-${var.name}"
}