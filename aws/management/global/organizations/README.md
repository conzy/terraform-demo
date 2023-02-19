# AWS Organizations

This is a critical workspace as it defines other AWS Accounts via AWS Organizations.

It also defines SCP, IAM Identity Center resources etc. Access to the management account should be locked down to a
handful of extremely privileged engineers.

## AWS IAM Identity Center 

We are using the built-in Identity Center Identity Store. In larger organisations you should integrate an existing IdP
such as Okta etc.
