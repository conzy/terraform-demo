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
  assume_role {
    role_arn = "arn:aws:iam::332594793360:role/terraform"
  }
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

# Here we can use the organization data source to compute all our accounts. We can use this to generate a list of
# terraform roles that should be assumable.
locals {
  all_accounts           = data.aws_organizations_organization.this.accounts
  target_terraform_roles = [for account in local.all_accounts : "arn:aws:iam::${account.id}:role/terraform"]
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

data "aws_s3_bucket" "org_formation_bucket" {
  bucket = "organization-formation-332594793360"
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${data.aws_s3_bucket.org_formation_bucket.arn}/organization.yml"
    ]
  }
}

module "oidc_github" {
  source  = "unfunco/oidc-github/aws"
  version = "1.2.1"

  github_repositories = [
    "conzy/actions-playground:*",
  ]
  attach_read_only_policy = false
  iam_role_inline_policies = {
    org-formation-state = data.aws_iam_policy_document.s3.json
  }
}
