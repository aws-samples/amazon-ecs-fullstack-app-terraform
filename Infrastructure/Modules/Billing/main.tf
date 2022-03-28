terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}
resource "aws_budgets_budget" "proof-of-concept" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = "20.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2021-07-20_00:01"
}
resource "aws_budgets_budget" "poc-daily" {
  name              = "daily-budget"
  budget_type       = "COST"
  limit_amount      = "5.0"
  limit_unit        = "USD"
  time_unit         = "DAILY"
  time_period_start = "2021-07-20_00:01"
}