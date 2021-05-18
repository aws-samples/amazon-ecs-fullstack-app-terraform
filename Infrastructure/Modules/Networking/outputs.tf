# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "aws_vpc" {
  value = aws_vpc.aws_vpc.id
}

output "public_subnets" {
  value = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]

}
output "private_subnets_client" {
  value = [aws_subnet.private_subnets_client[0].id, aws_subnet.private_subnets_client[1].id]
}

output "private_subnets_server" {
  value = [aws_subnet.private_subnets_server[0].id, aws_subnet.private_subnets_server[1].id]
}