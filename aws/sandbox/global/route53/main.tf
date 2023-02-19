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

resource "aws_route53_zone" "sandbox" {
  name = "sandbox.conormaher.com"
}
