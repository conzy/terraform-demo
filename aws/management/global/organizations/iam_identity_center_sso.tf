data "aws_ssoadmin_instances" "this" {}

# Some helpful locals
locals {
  instance_arn                   = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id              = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  development_account_ids        = [for account in aws_organizations_organizational_unit.development.accounts : account.id]
  all_non_management_account_ids = [for account in toset(aws_organizations_organization.management.non_master_accounts) : account.id]
  all_account_ids                = [for account in toset(aws_organizations_organization.management.accounts) : account.id]
  management_account_id          = aws_organizations_organization.management.master_account_id
  protected_account_ids          = [for account in aws_organizations_organizational_unit.protected.accounts : account.id]
}

# Users
resource "aws_identitystore_user" "conor" {
  identity_store_id = local.identity_store_id

  display_name = "Conor Maher"
  user_name    = "conor"

  name {
    given_name  = "Conor"
    family_name = "Maher"
  }

  emails {
    value = "conzymaher+demo@gmail.com"
  }
}

resource "aws_identitystore_user" "bob" {
  identity_store_id = local.identity_store_id

  display_name = "Bob LobLaw"
  user_name    = "bob"

  name {
    given_name  = "Bob"
    family_name = "LobLaw"
  }

  emails {
    value = "conzymaher+bob@gmail.com"
  }
}

resource "aws_identitystore_user" "luciano" {
  identity_store_id = local.identity_store_id

  display_name = "Luciano Mammino"
  user_name    = "luciano"

  name {
    given_name  = "Luciano"
    family_name = "Mammino"
  }

  emails {
    value = "luciano.mammino@fourtheorem.com"
  }
}

resource "aws_identitystore_user" "peter" {
  identity_store_id = local.identity_store_id

  display_name = "Peter Elger"
  user_name    = "peter"

  name {
    given_name  = "Peter"
    family_name = "Elger"
  }

  emails {
    value = "peter.elger@fourtheorem.com"
  }
}

resource "aws_identitystore_user" "eoin" {
  identity_store_id = local.identity_store_id

  display_name = "Eoin Shanaghy"
  user_name    = "eoin"

  name {
    given_name  = "Eoin"
    family_name = "Shanaghy"
  }

  emails {
    value = "eoin.shanaghy@fourtheorem.com"
  }
}

# Groups
resource "aws_identitystore_group" "super_admin" {
  display_name      = "Super Admin"
  description       = "A highly priviliged group for Cloud Wranglers"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "security" {
  display_name      = "Security"
  description       = "A group for Security Staff to view the posture of accounts"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "engineers" {
  display_name      = "Engineers"
  description       = "A group that is safe for all engineering to have access to"
  identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "finance" {
  display_name      = "Finance"
  description       = "A group for people who need access to billing"
  identity_store_id = local.identity_store_id
}

# Group Membership
locals {
  super_admins = {
    conor = aws_identitystore_user.conor.user_id
  }
  engineers = {
    bob = aws_identitystore_user.bob.user_id
  }
  security = {
    bob     = aws_identitystore_user.bob.user_id
    luciano = aws_identitystore_user.luciano.user_id
    peter   = aws_identitystore_user.peter.user_id
    eoin    = aws_identitystore_user.eoin.user_id
  }
  finance = {
    conor = aws_identitystore_user.conor.user_id
    bob   = aws_identitystore_user.bob.user_id
  }
}

resource "aws_identitystore_group_membership" "super_admin" {
  for_each          = local.super_admins
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.super_admin.group_id
  member_id         = each.value
}

resource "aws_identitystore_group_membership" "engineers" {
  for_each          = local.engineers
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.engineers.group_id
  member_id         = each.value
}

resource "aws_identitystore_group_membership" "security" {
  for_each          = local.security
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.security.group_id
  member_id         = each.value
}

resource "aws_identitystore_group_membership" "finance" {
  for_each          = local.finance
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.finance.group_id
  member_id         = each.value
}

# Permissions Sets
## View Only
resource "aws_ssoadmin_permission_set" "view_only" {
  name             = "view_only"
  description      = "A permission set that allows the canned view only policy"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "view_only" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.view_only.arn
}

## Admin
resource "aws_ssoadmin_permission_set" "admin" {
  name             = "admin"
  description      = "A permission set that allows the canned admin policy"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

# Account Assignments
## Allow Super Admins a safe view only role
resource "aws_ssoadmin_account_assignment" "super_admin_view" {
  for_each           = toset(local.all_account_ids)
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.view_only.arn

  principal_id   = aws_identitystore_group.super_admin.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}

## Allow Super Admins admin access into each account - this is for break glass
resource "aws_ssoadmin_account_assignment" "super_admin_admin" {
  for_each           = toset(local.all_account_ids)
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_id   = aws_identitystore_group.super_admin.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}

## Allow the security group a view only picture of each account
resource "aws_ssoadmin_account_assignment" "security_view" {
  for_each           = toset(local.all_account_ids)
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.view_only.arn

  principal_id   = aws_identitystore_group.security.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}

## Allow the engineers group admin on the sandbox account
resource "aws_ssoadmin_account_assignment" "engineers_sandbox_admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_id   = aws_identitystore_group.engineers.group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.sandbox.id
  target_type = "AWS_ACCOUNT"
}
