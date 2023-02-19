# An SCP policy with foundational security settings that should be applied to all accounts.
data "aws_iam_policy_document" "foundational_scp" {
  statement {
    sid       = "DenyLeavingOrgs"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"] # Hotel California
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
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
  statement {
    sid       = "RequireImdsV2"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "StringNotEquals"
      variable = "ec2:MetadataHttpTokens"
      values   = ["required"]
    }
  }
  statement {
    sid       = "DenyModifyInstanceMetadata"
    effect    = "Deny"
    actions   = ["ec2:ModifyInstanceMetadataOptions"]
    resources = ["*"]
  }
  statement {
    sid       = "MaxImdsHopLimit"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "NumericGreaterThan"
      variable = "ec2:MetadataHttpPutResponseHopLimit"
      values   = ["1"]
    }
  }
  statement {
    sid    = "DenyDisableSecurity"
    effect = "Deny"
    actions = [
      "access-analyzer:DeleteAnalyzer",
      "ec2:DisableEbsEncryptionByDefault",
      "s3:PutAccountPublicAccessBlock"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "DenyDisableSecurityTools"
    effect = "Deny"
    actions = [
      "guardduty:DeleteDetector",
      "guardduty:DisassociateFromMasterAccount",
      "guardduty:UpdateDetector",
      "guardduty:CreateFilter",
      "guardduty:CreateIPSet",
      "config:DeleteConfigRule",
      "config:DeleteConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "config:StopConfigurationRecorder",
      "cloudtrail:StopLogging",
      "cloudtrail:DeleteTrail",
      "securityhub:DeleteInvitations",
      "securityhub:DisableSecurityHub",
      "securityhub:DisassociateFromMasterAccount",
    ]
    resources = ["*"]
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
