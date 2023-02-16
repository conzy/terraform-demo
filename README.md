# Terraform Demo

A complete demo of a terraformed AWS environment suitable for a startup with Terraform Cloud Orchestration

## Design Principals

### Pragmatic

We are taking a pragmatic approach to terraform. We are aiming for very high infrastructure as code coverage.
Sometimes the last 5% of coverage can be difficult. We will strive for 100% coverage and document where we cant.

Its possible to make terraform code more DRY by adopting tooling such as terragrunt. We are willing to make the
configuration a little bit more verbose to keep the tooling and workflow simple.

### Building on the shoulders of giants

We want to do as little undifferentiated heavy lifting as possible. There are many battle tested robust community
[registry](https://registry.terraform.io/) modules. We should leverage them where possible.

[Terraform AWS Modules](https://github.com/terraform-aws-modules)

### KISS

Keep it simple stupid. It can be tempting to write "clever" terraform modules with lots of magic and configuration. These
modules tend to be difficult to modify / upgrade / refactor and you can often paint yourself into a corner.

We prefer a little more verbosity over complex / clever modules. e.g sometimes it is better to write two modules and have
each solve one problem well, even if this leads to some repetition.