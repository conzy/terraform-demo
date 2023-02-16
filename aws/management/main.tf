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
