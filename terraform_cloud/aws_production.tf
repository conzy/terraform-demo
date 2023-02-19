module "production_route53" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "production_route53"
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
    tfe_variable_set.cloudflare.id
  ]
  working_directory = "aws/production/global/route53"
  tag_names         = ["aws", "conzy-demo-production", "dns"]
  description       = "This workspace manages production Route53."
}

module "production_core" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "production_core"
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
  working_directory = "aws/production/core"
  tag_names         = ["aws", "conzy-demo-production"]
  description       = "This workspace manages state for production core infra."
}
