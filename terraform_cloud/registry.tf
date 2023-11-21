module "terraform_tfe_modules" {
  source         = "app.terraform.io/conzy-demo/modules/tfe//modules/registry"
  version        = "0.0.2"
  name           = "terraform-tfe-modules"
  enforce_admins = false
  description    = "Providers helper functions for Terraform Cloud."
  visibility     = "public"
  oauth_token_id = local.oauth_token_id
}

module "terraform_aws_s3" {
  source         = "app.terraform.io/conzy-demo/modules/tfe//modules/registry"
  version        = "0.0.2"
  name           = "terraform-aws-s3"
  enforce_admins = false
  description    = "An opinionated S3 module with sane defaults and naming convention."
  visibility     = "public"
  oauth_token_id = local.oauth_token_id
}

module "terraform_aws_modules" {
  source         = "app.terraform.io/conzy-demo/modules/tfe//modules/registry"
  version        = "0.0.2"
  name           = "terraform-aws-modules"
  enforce_admins = false
  description    = "Provides many helper modules for AWS infra."
  visibility     = "public"
  oauth_token_id = local.oauth_token_id
}

module "terraform_aws_networking" {
  source         = "app.terraform.io/conzy-demo/modules/tfe//modules/registry"
  version        = "0.0.2"
  name           = "terraform-aws-networking"
  enforce_admins = false
  description    = "Provides a complete VPC"
  visibility     = "public"
  oauth_token_id = local.oauth_token_id
}

module "terraform_aws_app" {
  source         = "app.terraform.io/conzy-demo/modules/tfe//modules/registry"
  version        = "0.0.2"
  name           = "terraform-aws-app"
  enforce_admins = false
  description    = "Provides a module that encapsulates a workload / app"
  visibility     = "public"
  check_contexts = ["lint", "integration"] # Require linting and integration tests to pass
  oauth_token_id = local.oauth_token_id
}

module "terraform_aws_alb" {
  source         = "app.terraform.io/conzy-demo/modules/tfe//modules/registry"
  version        = "0.0.2"
  name           = "terraform-aws-alb"
  enforce_admins = false
  description    = "This is a demo repo / module for the South East User Group"
  visibility     = "public"
  check_contexts = ["lint"]
  oauth_token_id = local.oauth_token_id
}
