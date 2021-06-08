# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

/*====================================================
      AWS SNS topic for deployment notifications
=====================================================*/

resource "aws_sns_topic" "sns_notifications" {
  name = var.sns_name
}