module "staging_route53" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "staging_route53"
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
  working_directory = "aws/staging/global/route53"
  tag_names         = ["aws", "conzy-demo-staging", "dns"]
  description       = "This workspace manages staging Route53."
}


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

module "staging_vpc" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "staging_vpc"
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
  working_directory = "aws/staging/vpc"
  tag_names         = ["aws", "conzy-demo-staging", "vpc"]
  description       = "This workspace manages state for staging vpc infra."
}
