# Note these are all populated in Terraform Cloud

resource "tfe_variable_set" "terraform_cloud_token" {
  name         = "Terraform Cloud Token"
  description  = "The token that allows us to interact with Terraform Cloud."
  organization = tfe_organization.organization.id
}

resource "tfe_variable_set" "aws_iam_user" {
  name         = "AWS IAM User in Management Account"
  description  = "Allows us to assume a role in target accounts."
  organization = tfe_organization.organization.id
}

resource "tfe_variable_set" "github_token" {
  name         = "GitHub Token"
  description  = "GitHub Personal Access Token"
  organization = tfe_organization.organization.id
}

resource "tfe_variable_set" "slack" {
  name         = "Slack Webhook URL"
  description  = "Used for Terraform Cloud Slack integration."
  organization = tfe_organization.organization.id
}

resource "tfe_variable_set" "cloudflare" {
  name         = "Cloudflare Token"
  description  = "Cloudflare API Token"
  organization = tfe_organization.organization.id
}
