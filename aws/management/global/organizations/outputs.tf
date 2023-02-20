output "account_ids" {
  value = local.all_account_ids
}

output "security_account_id" {
  value = aws_organizations_account.security.id
}

output "management_account_id" {
  value = local.management_account_id
}

output "all_non_management_account_ids" {
  value = local.all_non_management_account_ids
}
