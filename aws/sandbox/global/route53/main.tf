terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
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

data "cloudflare_zone" "conormaher_com" {
  name = "conormaher.com"
}

resource "cloudflare_record" "sandbox" {
  for_each = toset(aws_route53_zone.sandbox.name_servers)
  zone_id  = data.cloudflare_zone.conormaher_com.id
  name     = "sandbox"
  value    = each.key
  type     = "NS"
  ttl      = 60 # Low for demo purposes
}
