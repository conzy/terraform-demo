terraform {
  required_providers {
    tfe = {
      version = ">= 0.36.1"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "tfe" {
  hostname = "app.terraform.io"
  #token    = var.token
}

provider "github" {
  token = var.github_token
}

locals {
  oauth_token_id = data.tfe_oauth_client.client.oauth_token_id
}

# Gets info about our VCS Provider
data "tfe_oauth_client" "client" {
  organization     = tfe_organization.organization.id
  service_provider = "github"
}

# Creates our Terraform Cloud Org
resource "tfe_organization" "organization" {
  name  = "conzy-demo"
  email = "conzymaher+demo@gmail.com"
}