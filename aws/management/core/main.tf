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
    role_arn = "arn:aws:iam::332594793360:role/terraform"
  }
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "conzy-demo"
    workspaces {
      name = "management_core"
    }
  }
}

module "core" {
  source             = "app.terraform.io/conzy-demo/modules/aws//modules/core"
  version            = "0.0.2"
  name               = "conzy-demo-management"
  config_bucket_name = "conzy-demo-security-eu-west-1-config"
  trusted_role_arns  = ["arn:aws:iam::332594793360:user/terraform"]
}

module "security" {
  source            = "app.terraform.io/conzy-demo/modules/aws//modules/management_account_security"
  version           = "0.0.2"
  cloudtrail_bucket = "conzy-demo-security-eu-west-1-cloudtrail"
}
