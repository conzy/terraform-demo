# An SCP policy with foundational security settings that should be applied to all accounts.
data "aws_iam_policy_document" "foundational_scp" {
  statement {
    sid       = "DenyLeavingOrgs"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
  }
  statement {
    sid    = "DenyCreatingIAMUsers"
    effect = "Deny"
    actions = [
      "iam:CreateUser",
      "iam:CreateAccessKey"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "DenyRootAccount"
    actions   = ["*"]
    resources = ["*"]
    effect    = "Deny"
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

resource "aws_organizations_policy" "foundational_scp" {
  name    = "foundational_scp"
  content = data.aws_iam_policy_document.foundational_scp.json
}

resource "aws_organizations_policy_attachment" "foundational_scp" {
  policy_id = aws_organizations_policy.foundational_scp.id
  target_id = aws_organizations_organization.management.roots[0].id
}
