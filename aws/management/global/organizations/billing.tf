data "aws_iam_policy_document" "billing" {
  statement {
    actions = [
      "ce:Get*",
      "ce:Describe*",
      "ce:List*",
      "ce:CreateReport",
      "ce:UpdateReport",
      "ce:GetAnomalies",
      "account:GetAccountInformation",
      "billing:Get*",
      "payments:List*",
      "payments:Get*",
      "tax:List*",
      "tax:Get*",
      "consolidatedbilling:Get*",
      "consolidatedbilling:List*",
      "invoicing:List*",
      "invoicing:Get*",
      "cur:Get*",
      "cur:Validate*",
      "freetier:Get*",
    ]
    resources = ["*"]
  }
  statement {
    sid = "LegacyPermissions"
    actions = [
      "aws-portal:ViewUsage",
      "aws-portal:ViewBilling",
      "aws-portal:ViewAccount",
    ]
    resources = ["*"]
  }
}

# Billing
resource "aws_ssoadmin_permission_set" "billing" {
  name             = "billing"
  description      = "A role that allows access to billing and reports."
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "billing" {
  inline_policy      = data.aws_iam_policy_document.billing.json
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.billing.arn
}

resource "aws_ssoadmin_account_assignment" "finance_billing_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.billing.arn

  principal_id   = aws_identitystore_group.finance.group_id
  principal_type = "GROUP"

  target_id   = local.management_account_id
  target_type = "AWS_ACCOUNT"
}
