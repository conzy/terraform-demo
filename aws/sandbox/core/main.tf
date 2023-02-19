terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::854268402788:role/OrganizationAccountAccessRole"
  }
}

module "core" {
  source  = "app.terraform.io/conzy-demo/modules/aws//modules/core"
  version = "0.0.1"
  name    = "conzy-demo-sandbox"
}
