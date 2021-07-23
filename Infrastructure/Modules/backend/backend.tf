terraform {
  backend "s3" {
    bucket = "my-tf-remotestate"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}