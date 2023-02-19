terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = var.github_token
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "conzy-demo"
    workspaces {
      name = "github"
    }
  }
}

# Defines a template repo that we use to cookie-cutter our terraform module repos
resource "github_repository" "terraform_module_template" {
  name        = "terraform-module-template"
  description = "A template repo used for creating terraform module repos"
  is_template = true
  visibility  = "public"
}

# Defines _this_ repo we are currently using. Inception. Deleting this resource is the equivalent of dragging and
# dropping the My Computer icon into the Recycling Bin https://media.tenor.com/EWZCUGkCcIsAAAAd/old-man-my-computer.gif
resource "github_repository" "terraform_demo" {
  name                   = "terraform-demo"
  delete_branch_on_merge = true
  description            = "A repo to demonstrate a complete Terraform Demo"
  visibility             = "private"
  archive_on_destroy     = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_protection" "terraform_demo_protection" {
  repository_id  = github_repository.terraform_demo.name
  pattern        = "main"
  enforce_admins = false

  required_status_checks {
    strict   = false
    contexts = ["lint"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews = true
  }
}

# Lets add some collaborators!
locals {
  collaborators = {
    eoinsha  = "pull"
    pelger   = "pull"
    lmammino = "pull"
  }
}

resource "github_repository_collaborator" "collaborators" {
  for_each   = local.collaborators
  repository = github_repository.terraform_demo.id
  username   = each.key
  permission = each.value
}
