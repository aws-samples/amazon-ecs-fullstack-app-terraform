# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "sns_arn" {
  value = aws_sns_topic.sns_notifications.arn
}