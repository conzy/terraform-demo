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
    role_arn = "arn:aws:iam::854268402788:role/terraform"
  }
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "conzy-demo"
    workspaces {
      name = "sandbox_core"
    }
  }
}

module "core" {
  source             = "app.terraform.io/conzy-demo/modules/aws//modules/core"
  version            = "0.0.2"
  config_bucket_name = "conzy-demo-security-eu-west-1-config"
  name               = "conzy-demo-sandbox"
  trusted_role_arns  = ["arn:aws:iam::332594793360:user/terraform"]
}

# We create a role here that uses GitHub OIDC Web Identity Federation for running integration tests from GH Actions
# https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token
# Note a forked repo _cannot_ abuse this.
module "oidc_github" {
  source  = "unfunco/oidc-github/aws"
  version = "1.2.1"

  github_repositories = [
    "conzy/terraform-aws-app:*",
  ]
  attach_admin_policy = true # This is a sandbox environment!
}
