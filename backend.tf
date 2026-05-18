terraform {
  backend "s3" {
    bucket = "clc15-pacheco-terraform"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
