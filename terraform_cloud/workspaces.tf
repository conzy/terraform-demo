module "test" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  organization      = tfe_organization.organization.id
  slack_webhook_url = var.slack_webhook_url
  name              = "test"
  teams             = {}
}

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
    identifier     = "conzy/infra"
    oauth_token_id = local.oauth_token_id
    branch         = "main"
  }
  variable_sets = [
    tfe_variable_set.terraform_cloud_token.id,
    tfe_variable_set.github_token.id
  ]
  working_directory = "terraform_cloud"
  tag_names         = ["terraform", "conzy-demo", "tfe"]
  description       = "This workspace manages state for our Terraform Cloud configuration."
}

# Staging

module "staging_core" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "staging_core"
  terraform_version = "1.3.9"
  organization      = tfe_organization.organization.id
  teams             = {}
  vcs_repo = {
    identifier     = "conzy/terraform-demo"
    oauth_token_id = local.oauth_token_id
    branch         = "main"
  }
  variable_sets = [
    tfe_variable_set.aws_iam_user.id
  ]
  working_directory = "aws/staging/core"
  tag_names         = ["aws", "conzy-demo-staging"]
  description       = "This workspace manages state for staging core infra."
}
