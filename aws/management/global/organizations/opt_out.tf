# This opts us out of AWS using our data to improve AI services (it can result in data leaving the region)

resource "aws_organizations_policy" "opt_out" {
  name        = "optout"
  type        = "AISERVICES_OPT_OUT_POLICY"
  description = "Opt out of AI services using our data"
  content     = <<CONTENT
{
    "services": {
        "@@operators_allowed_for_child_policies": ["@@none"],
        "default": {
            "@@operators_allowed_for_child_policies": ["@@none"],
            "opt_out_policy": {
                "@@operators_allowed_for_child_policies": ["@@none"],
                "@@assign": "optOut"
            }
        }
    }
}
CONTENT
}

resource "aws_organizations_policy_attachment" "root_opt_out" {
  policy_id = aws_organizations_policy.opt_out.id
  target_id = aws_organizations_organization.management.roots[0].id
}
