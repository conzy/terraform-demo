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
      name = "staging_core"
    }
  }
}

module "core" {
  source            = "app.terraform.io/conzy-demo/modules/aws//modules/core"
  version           = "0.0.1"
  name              = "conzy-demo-staging"
  trusted_role_arns = ["arn:aws:iam::332594793360:user/terraform"]
}
