# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "arn_alb" {
  value = (var.create_alb == true
  ? (length(aws_alb.alb) > 0 ? aws_alb.alb[0].arn : "") : "")
}
output "arn_tg" {
  value = (var.create_target_group == true
  ? (length(aws_alb_target_group.target_group) > 0 ? aws_alb_target_group.target_group[0].arn : "") : "")
}

output "tg_name" {
  value = (var.create_target_group == true
  ? (length(aws_alb_target_group.target_group) > 0 ? aws_alb_target_group.target_group[0].name : "") : "")
}

output "arn_listener" {
  value = (var.create_alb == true
  ? (length(aws_alb_listener.http_listener) > 0 ? aws_alb_listener.http_listener[0].arn : "") : "")
}

output "dns_alb" {
  value = (var.create_alb == true
  ? (length(aws_alb.alb) > 0 ? aws_alb.alb[0].dns_name : "") : "")
}