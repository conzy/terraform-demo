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
    role_arn = "arn:aws:iam::782190888228:role/terraform"
  }
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "conzy-demo"
    workspaces {
      name = "staging_vpc"
    }
  }
}

module "vpc" {
  source            = "app.terraform.io/conzy-demo/networking/aws"
  version           = "0.0.1"
  high_availability = false # Less NAT Gateways, More pizza money
}
