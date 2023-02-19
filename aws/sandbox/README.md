# Sandbox

This account can be used as a target for local terraform development. When working alone or on a small team a single
sandbox account tends to be sufficient, for larger teams it makes sense to create an account per person. In small
organisations I have found just repeating the patterns in this repo sufficient, e.g for about a dozen development accounts.

For environments where you might need 100s of development accounts this approach will burst at the seams and you need
to investigate alternative approaches.
The [Control Tower Account Factory for Terraform](https://developer.hashicorp.com/terraform/tutorials/aws/aws-control-tower-aft)
is one such approach, its certainly on my R&D list, but I have not needed it yet.

## Using this account

My typical workflow would be to develop 