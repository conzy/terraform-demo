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
    role_arn = "arn:aws:iam::103317967445:role/terraform"
  }
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "conzy-demo"
    workspaces {
      name = "security_core"
    }
  }
}

module "core" {
  source             = "app.terraform.io/conzy-demo/modules/aws//modules/core"
  version            = "0.0.2"
  config_bucket_name = module.security.config_bucket_name
  name               = "conzy-demo-security"
  trusted_role_arns  = ["arn:aws:iam::332594793360:user/terraform"]
}

module "security" {
  source  = "app.terraform.io/conzy-demo/modules/aws//modules/security_account"
  version = "0.0.2"
  #TODO These can be retrieved from remote state
  management_account_id = "332594793360"
  organization_accounts = [
    "854268402788",
    "782190888228",
    "671953853133",
    "332594793360",
    "103317967445",
  ]
}
