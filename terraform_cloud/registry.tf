module "test_module" {
  source         = "../../terraform-tfe-modules//modules/registry"
  name           = "terraform-tfe-foobar"
  oauth_token_id = local.oauth_token_id
  enforce_admins = false
}

module "terraform_tfe_modules" {
  source         = "app.terraform.io/conzy-demo/modules/tfe//modules/registry"
  version        = "0.0.1"
  name           = "terraform-tfe-modules"
  description    = "Providers helper functions for Terraform Cloud."
  visibility     = "public"
  oauth_token_id = local.oauth_token_id
}

module "terraform_aws_s3" {
  source         = "app.terraform.io/conzy-demo/modules/tfe//modules/registry"
  version        = "0.0.1"
  name           = "terraform-aws-s3"
  description    = "An opinionated S3 module with sane defaults and naming convention."
  visibility     = "public"
  oauth_token_id = local.oauth_token_id
}

module "terraform_aws_modules" {
  source         = "app.terraform.io/conzy-demo/modules/tfe//modules/registry"
  version        = "0.0.1"
  name           = "terraform-aws-modules"
  description    = "Provides many helper modules for AWS infra."
  visibility     = "public"
  oauth_token_id = local.oauth_token_id
}
