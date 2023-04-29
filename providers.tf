terraform {
  required_providers {
    aws = {
      version = "4.54.0"
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "sri-tfstate-backend"
    key = "cointracker-project-tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  allowed_account_ids = [
    var.account_number
  ]
}
