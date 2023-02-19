module "management_organizations" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "management_organizations"
  terraform_version = "1.3.9"
  organization      = tfe_organization.organization.id
  teams             = {}
  vcs_repo = {
    identifier     = "conzy/terraform-demo"
    oauth_token_id = local.oauth_token_id
    branch         = "main"
  }
  variable_sets = [
    tfe_variable_set.aws_iam_user.id,
  ]
  remote_state_consumer_ids = [
    module.security_core.workspace_id
  ]
  working_directory = "aws/management/global/organizations"
  tag_names         = ["aws", "conzy-demo-management", "organizations"]
  description       = "This workspace manages AWS Organizations in management account."
  execution_mode    = "local"
}

module "management_iam" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "management_iam"
  terraform_version = "1.3.9"
  organization      = tfe_organization.organization.id
  teams             = {}
  vcs_repo = {
    identifier     = "conzy/terraform-demo"
    oauth_token_id = local.oauth_token_id
    branch         = "main"
  }
  variable_sets = [
    tfe_variable_set.aws_iam_user.id,
  ]
  working_directory = "aws/management/global/iam"
  tag_names         = ["aws", "conzy-demo-management", "iam"]
  description       = "This workspace manages IAM in management account."
  execution_mode    = "local"
}

module "management_core" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "management_core"
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
  working_directory = "aws/management/core"
  tag_names         = ["aws", "conzy-demo-management"]
  description       = "This workspace manages state for management core infra."
  execution_mode    = "local"
}
