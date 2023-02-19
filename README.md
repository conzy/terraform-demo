# Terraform Demo

A complete demo of a terraformed AWS environment suitable for a startup with Terraform Cloud Orchestration

## Repos

| Repo                                               | Description                                                            |
|----------------------------------------------------|------------------------------------------------------------------------|
| https://github.com/conzy/terraform-demo            | This repo. Orchestrates everything                                     |
| https://github.com/conzy/terraform-module-template | A template repo that all other terraform module repos are created from |
| https://github.com/conzy/terraform-aws-s3          | An opinionated S3 module with sane defaults and naming convention.     |
| https://github.com/conzy/terraform-tfe-modules     | Providers helper functions for Terraform Cloud.                        |
| https://github.com/conzy/terraform-aws-modules     | Provides helper modules for AWS infra.                                 |
| https://github.com/conzy/terraform-aws-networking  | Provides a complete VPC                                                |
| https://github.com/conzy/terraform-aws-app         | Provides a module that encapsulates a workload / app                   |
## Design Principals

### Pragmatic

We are taking a pragmatic approach to terraform. We are aiming for very high infrastructure as code coverage.
Sometimes the last 5% of coverage can be difficult. We will strive for 100% coverage and document where we can't.

Its possible to make terraform code more DRY by adopting tooling such as terragrunt. We are willing to make the
configuration a little bit more verbose to keep the tooling and workflow simple.

### Well Architected

The [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected) particularly the 
[Security Pillars](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html) are front of mind when
designing the project. 

The [Scott Piper AWS Security Maturity Roadmap](https://summitroute.com/downloads/aws_security_maturity_roadmap-Summit_Route.pdf) is
also an excellent with pragmatic and actionable advice.

> This demo may not have exhaustive coverage of everything outlined in the framework but it's a good starting point.


### Building on the shoulders of giants

We want to do as little undifferentiated heavy lifting as possible. There are many battle tested robust community
[registry](https://registry.terraform.io/) modules. We should leverage them where possible.

[Terraform AWS Modules](https://github.com/terraform-aws-modules)

### Blast Radius / State Isolation

This depends on your risk appetite. You could have one giant terraform state per account. This is not good practice,
there are many ways to approach this but the most effective pattern I have arrived at is splitting workloads by change
cadence and risk. What do I mean by this?

Often your core IAM will rarely change, it may establish some trust relationships and high level critical configuration,
it may only be touched a handful of times in the lifetime of the account. This should be its own state. It should have
least privilege access and only super admins should be able to approve changes to it. Similarly, VPC and RDS configuration
will only change a handful of times per year. You end up with a cadence / workload pattern like this

| Workload             | Update Cadence             | Risk   |
|----------------------|----------------------------|--------|
| Core IAM             | 1-2 times ever             | High   |
| Core Route53 Config  | 1-2 times per year         | Medium |
| VPC                  | 3-4 times per year         | Medium |
| RDS                  | 12 times per year          | High   |
| S3                   | 36 times per year          | Medium |
| EC2 / ALB Workloads  | handful of times per month | Low    |
| Stateless Workloads  | dozens of times per month  | Low    |
| Serverless Workloads | dozens of times per week   | Low    |

As the custodians of the cloud it's important for us to create an environment that strikes that ideal balance between risk
and agility for the organisation. The last thing we want is some workload that bundles an RDS Cluster with a Lambda app
and some poor junior engineer updates a single line of Python which causes a production outage because there
was a hidden RDS Engine upgrade lurking in the `terraform plan`

More workspaces has some management overhead, you'll sometimes need to share information between workspaces, you'll sometimes
need to update resources in multiple files. But you _cannot_ put a price on the operational safety you gain.

### KISS

Keep it simple stupid. It can be tempting to write "clever" terraform modules with lots of magic and configuration. These
modules tend to be difficult to modify / upgrade / refactor and you can often paint yourself into a corner.

We prefer a little more verbosity over complex / clever modules. e.g sometimes it is better to write two modules and have
each solve one problem well, even if this leads to some repetition.

## Resources Under Management

This repo manages resources across:

- Multiple AWS Accounts
- Terraform Cloud
- GitHub
- CloudFlare