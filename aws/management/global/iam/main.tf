data "aws_organizations_organization" "this" {}

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
  //  assume_role {
  //    role_arn = "arn:aws:iam::332594793360:role/terraform"
  //  }
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "conzy-demo"
    workspaces {
      name = "management_iam"
    }
  }
}

# This credentials for this IAM user are stored in a variable set in Terraform Cloud
# This should be the _only_ IAM user in the entire Organization! IAM Users with long lived credentials should be avoided.
resource "aws_iam_user" "terraform" {
  name = "terraform"
  tags = {
    type = "machine"
  }
}

# Here we can use the organization data source to compute all our accounts We can use this to generate a list of
# terraform roles that should be assumable.
locals {
  all_accounts           = data.aws_organizations_organization.this.accounts
  target_terraform_roles = [for account in local.all_accounts : "arn:aws:iam::${account.id}:role/terraform"]
}

output "roles" {
  value = local.target_terraform_roles
}

# We attach policies via a group as per CIS Standard
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.16
module "terraform_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "4.5.0"
  name    = "terraform_assume"

  assumable_roles = local.target_terraform_roles

  group_users = [
    aws_iam_user.terraform.name
  ]
}
