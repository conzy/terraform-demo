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
    role_arn = "arn:aws:iam::103317967445:role/OrganizationAccountAccessRole"
  }
}

module "core" {
  source = "../../../../terraform-aws-modules//modules/core"
  name   = "conzy-demo-security"
}
