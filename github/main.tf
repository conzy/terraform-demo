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

resource "github_repository" "terraform_module_template" {
  name        = "terraform-module-template"
  description = "A template repo used for creating terraform module repos"
  is_template = true
  visibility  = "public"
}

# Defines _this_ repo we are currently using. Inception. Deleting this resource is the equivalent of dragging and
# dropping the My Computer icon into the Recycling Bin https://media.tenor.com/EWZCUGkCcIsAAAAd/old-man-my-computer.gif
resource "github_repository" "terraform_demo" {
  name               = "terraform-demo"
  description        = "A repo to demonstrate a complete Terraform Demo"
  visibility         = "private"
  archive_on_destroy = true
  lifecycle {
    prevent_destroy = true
  }
}
