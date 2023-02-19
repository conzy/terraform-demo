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
}

resource "aws_organizations_organization" "management" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
    "sso.amazonaws.com",
    "ram.amazonaws.com",
    "securityhub.amazonaws.com",
    "guardduty.amazonaws.com",
    "storage-lens.s3.amazonaws.com",
  ]
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "AISERVICES_OPT_OUT_POLICY",
  ]
  feature_set = "ALL"
}

# We may apply different standard to development accounts VS Protected accounts. Create OU hierarchy
resource "aws_organizations_organizational_unit" "development" {
  name      = "development"
  parent_id = aws_organizations_organization.management.roots[0].id
}

resource "aws_organizations_organizational_unit" "protected" {
  name      = "protected"
  parent_id = aws_organizations_organization.management.roots[0].id
}

resource "aws_organizations_account" "production" {
  email     = "conzymaher+demo-production@gmail.com"
  name      = "conzy-demo-production"
  parent_id = aws_organizations_organizational_unit.protected.id
  tags = {
    environment = "production"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "staging" {
  email     = "conzymaher+demo-staging@gmail.com"
  name      = "conzy-demo-staging"
  parent_id = aws_organizations_organizational_unit.protected.id
  tags = {
    environment = "staging"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "security" {
  email     = "conzymaher+demo-security@gmail.com"
  name      = "conzy-demo-security"
  parent_id = aws_organizations_organizational_unit.protected.id
  tags = {
    environment = "security"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "sandbox" {
  email     = "conzymaher+demo-sandbox@gmail.com"
  name      = "conzy-demo-sandbox"
  parent_id = aws_organizations_organizational_unit.development.id
  tags = {
    environment = "sandbox"
  }
  lifecycle {
    prevent_destroy = true
  }
}
