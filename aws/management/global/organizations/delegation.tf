# Delegate Guardduty Admin
resource "aws_guardduty_organization_admin_account" "delegated_admin" {
  admin_account_id = aws_organizations_account.security.id
}

# Delegate config admin
resource "aws_organizations_delegated_administrator" "config" {
  account_id        = aws_organizations_account.security.id
  service_principal = "config.amazonaws.com"
}

# Delegate Security Hub admin
resource "aws_securityhub_organization_admin_account" "this" {
  admin_account_id = aws_organizations_account.security.id
}
