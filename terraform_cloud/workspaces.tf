
# This creates the workspace which manages _this_ workspace
module "meta" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "tfe_workspace"
  terraform_version = "1.3.9"
  organization      = tfe_organization.organization.id
  teams             = {}
  vcs_repo = {
    identifier     = "conzy/terraform-demo"
    oauth_token_id = local.oauth_token_id
    branch         = "main"
  }
  variable_sets = [
    tfe_variable_set.terraform_cloud_token.id,
    tfe_variable_set.github_token.id,
    tfe_variable_set.slack.id
  ]
  working_directory = "terraform_cloud"
  tag_names         = ["terraform", "conzy-demo", "tfe"]
  description       = "This workspace manages state for our Terraform Cloud configuration."
  execution_mode    = "local"
}

# GitHub

module "github" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "github"
  terraform_version = "1.3.9"
  organization      = tfe_organization.organization.id
  teams             = {}
  vcs_repo = {
    identifier     = "conzy/terraform-demo"
    oauth_token_id = local.oauth_token_id
    branch         = "main"
  }
  variable_sets = [
    tfe_variable_set.github_token.id
  ]
  working_directory = "github"
  tag_names         = ["github"]
  description       = "This workspace manages core GitHub resources."
}

# Cloudflare

module "cloudflare" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "cloudflare"
  terraform_version = "1.3.9"
  organization      = tfe_organization.organization.id
  teams             = {}
  vcs_repo = {
    identifier     = "conzy/terraform-demo"
    oauth_token_id = local.oauth_token_id
    branch         = "main"
  }
  variable_sets = [
    tfe_variable_set.cloudflare.id
  ]
  working_directory = "cloudflare"
  tag_names         = ["cloudflare", "dns"]
  description       = "This workspace manages Cloudflare for DNS Zone Delegation"
}
