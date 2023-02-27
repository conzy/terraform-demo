# Terraform Demo

A complete demo of a terraformed AWS environment suitable for a startup with Terraform Cloud Orchestration

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

The Scott Piper [AWS Security Maturity Roadmap](https://summitroute.com/downloads/aws_security_maturity_roadmap-Summit_Route.pdf) is
also an excellent guide with pragmatic and actionable advice.

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
| Core IAM / Security  | 1-2 times ever             | High   |
| Core Route53 Config  | 1-2 times per year         | Medium |
| VPC                  | 3-4 times per year         | Medium |
| RDS                  | 12 times per year          | High   |
| S3                   | handful of times per month | Medium |
| EC2 / ALB Workloads  | handful of times per month | Low    |
| Stateless Workloads  | dozens of times per month  | Low    |
| Serverless Workloads | dozens of times per week   | Low    |

As the custodians of the cloud it's important for us to create an environment that strikes that ideal balance between risk
and agility for the business. The last thing we want is some workload that bundles an RDS Cluster with a Lambda app
and some poor junior engineer updates a single line of Python which causes a production outage because there
was a hidden RDS Engine upgrade lurking in the `terraform plan`

More workspaces has some management overhead, you'll sometimes need to share information between workspaces, you'll sometimes
need to update resources in multiple files. But you _cannot_ put a price on the operational safety you gain.

### KISS

Keep it simple stupid. It can be tempting to write "clever" terraform modules with lots of magic that are highly configurable. 
These modules can be difficult to reason about and tend to be difficult to modify / upgrade / refactor. You can often paint yourself 
into a corner.

We prefer a little more verbosity over complex / clever modules. e.g sometimes it is better to write two modules and have
each solve one problem well, even if this leads to some repetition.

## Resources Under Management

This repo manages resources across:

- Multiple AWS Accounts
- Terraform Cloud
- GitHub
- CloudFlare

## GitHub OpenID Connect AWS Integration

While all AWS Orchestration from this repo happens in Terraform Cloud. I want to be able to run intergration tests against
a real AWS account.

As we know IAM Users are the root of all evil. We can configure AWS to trust GitHub's OIDC as a federated identity, we
can then have fine-grained access at the repo level, or even at the branch / tag level to a role in an AWS Account!

There is even a great [community module](https://registry.terraform.io/modules/unfunco/oidc-github/aws/latest) to allow this

```hcl
module "oidc_github" {
  source  = "unfunco/oidc-github/aws"
  version = "1.2.1"

  github_repositories = [
    "conzy/terraform-aws-app:*",
  ]
}
```

## Repos used in this demo

| Repo                                               | Description                                                            |
|----------------------------------------------------|------------------------------------------------------------------------|
| https://github.com/conzy/terraform-demo            | This repo. Orchestrates everything                                     |
| https://github.com/conzy/terraform-module-template | A template repo that all other terraform module repos are created from |
| https://github.com/conzy/terraform-aws-s3          | An opinionated S3 module with sane defaults and naming convention.     |
| https://github.com/conzy/terraform-tfe-modules     | Providers helper functions for Terraform Cloud.                        |
| https://github.com/conzy/terraform-aws-modules     | Provides helper modules for AWS infra.                                 |
| https://github.com/conzy/terraform-aws-networking  | Provides a complete VPC                                                |
| https://github.com/conzy/terraform-aws-app         | Provides a module that encapsulates a workload / app                   |

## Security Services

### Cloudtrail

CloudTrail [delegated administrator support](https://aws.amazon.com/about-aws/whats-new/2022/11/aws-cloudtrail-delegated-account-support-aws-organizations/)
arrived relatively recently in November 2022. However, there are still issues related to the implementation with terraform
see issue [here](https://github.com/hashicorp/terraform-provider-aws/issues/28440)

For that reason I have arrived at a solution which I think is a good compromise. There is a Cloutrail Organization trail
in the management account, this monitors all accounts and regions. It creates a Cloudwatch Log Group in the management
account which is very convenient for investigating via Cloudwatch Logs Insights. I have also configured Cloudtrail to log
to an S3 bucket in the Security account so that logs are also stored outside of the management account and security teams
could investigate those logs in the Security account.

### GuardDuty and Security Hub

The Security Account is designated as the delegated administrator for both GuardDuty and Security Hub.

### Config

AWS Config is deployed in each account via our `core` module, it logs to a centralised bucket in the security account.
There is also an aggregator in the Config account.


## Work In Progress

What is not yet done but coming soon

### CIS AWS Foundations Benchmark

The [CIS AWS Foundations Benchmark](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls-1.4.0.html)
defines a lot of sensible security controls. AWS Security Hub can track your compliance.

# Log

> Note: This is essentially my rough work for the project. Hopefully gives some insight into how it came together. but is
> certainly missing steps. 

Created a 1password vault for the project

## Terraform Cloud

Create an account on https://app.terraform.io/app

Confirm Email

This should be the only Click Ops Needed here!

## AWS

Create a root account
Add payment method
Hope you are not bankrupted
Immideitely add MFA to root account, Ideally this is a hardware device. Seen as this is a demo project I use a virtual MFA device in 1password.

### Creating a temporary IAM User for myself

Its bad practice to create access keys for the root user. But I need _some_ user to initially bootstrap the account. I will click an IAM user with MFA into existence, I will add MFA and give it the administrator policy. I can than create access keys and use these for programmatic access via terraform. I will then be able to terraform some AWS IAM Identity Center resources and switch to that for my Console and Programmatic access.

After some of these initial chicken / egg problems are overcome the IAM user can be removed. An SCP policy will then be created so that further IAM users cannot be created.

**Note:** For this project we will probably still end up with one IAM User for terraform cloud. In production environments IAM Users and long lived credentials should be avoided at all costs. e.g we will use the GitHub Actions OIDC Support to get federated access to AWS for any interaction between GitHub and our AWS environments.

But we will need the `terrform` IAM user for interacting with AWS from Terraform Cloud. On Business and Enterprise plans which are $$$$ and beyond the scope of this demo, you can actually host your own [Terraform Cloud Agents](https://developer.hashicorp.com/terraform/cloud-docs/agents) this would allow you to use role assumption via an ECS Fargate task role for example and avoid long lived credentials. I have implemented this before and it works well but you need relatively deep pockets.

### Log out of root account

At this point you can put the keys back through the letterbox. I don't imagine myself needing the root account again for this project, its needed so rarely these days. Thats why the hardware MFA can often end up in a safety deposit box or with other important company documents.

### Log in as the IAM User

Lets login as the IAM user, add MFA, and generate some access keys.

I use aws-vault to manage credentials locally, this stores an encrypted copy of your access keys in the macOS keychain to protect against malware and credential exfiltration from `~/.aws/credentials`

`aws-vault add demo`

Now lets check our creds are working with the aws `whoami`

```
aws-vault exec demo -- aws sts get-caller-identity
{
    "UserId": "AIDAU24BRZOIPTGZP5OYO",
    "Account": "332594793360",
    "Arn": "arn:aws:iam::332594793360:user/conor"
}
```

## Terraform

Install `tfenv` it works just like `pyenv` or `nodenv` very handy when you interact with dozens of terraform projects. Explores the directory structure and choses the first `.terraform-version` it encounters

`tfenv install` will install the terraform binary. `terraform login` will bring you to terraform cloud to create a token and then ask for the token. Its stored in `~/.terraform.d/credentials.tfrc.json`

We can now interact with our Terraform Cloud account, pull registry modules, use Terraform Cloud workspaces to manage remote state and locking etc. We have some chicken / egg hurldes to overcome here also, once the account is sufficiently bootstrapped the workspace that manages terraform cloud will be a hosted in Terraform Cloud itself and we will use gitops to manage all future changes.


## Click ops

Terraform Cloud <> GitHub oauth app
Slack Webhook Creation in Slack

## Bootstrapping / Terraform Cloud 

This part is fun. Like changing the engine on an aircraft in the air! Now that we have some sensible baseline infra. We are now in a position to move to Terraform Cloud orchestration. Terraform Cloud will become authoritave and it will no longer be possible to make manual changes to infra.
As the workspace will require peer reviewed changes via the configured VCS provider.

## Initial Terraforming of new Accounts

This presents another chicken / egg problem. Eventually we want to create a terraform role called `terraform` in each of our target accounts. But right now they are empty. And we have an SCP policy that blocks root account usage. How do we access those accounts?

Each organization member account has a role that is implicitly created called `OrganizationAccountAccessRole` this role has a trust relationship that trusts the Organization management account.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::332594793360:root"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

So we can assume this role from the management account. You can use the role switcher in the AWS Console to take a look,
its not very exciting, just an empty account. What we really want to do is terraform resources in the context of these new
accounts. You can do that by creating a provider in the context of an assumed role

```hcl
provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::854268402788:role/OrganizationAccountAccessRole"
  }
}
```

Once we deploy some of our core infra we will update this role to `arn:aws:iam::854268402788:role/terraform` this can be
repeated for each account. What do I mean by core infra? We can create a module that creates the sensible baseline infra
that each and every account should have:

- Set an AWS IAM Account Alias
- Create a terraform role that we can assume to terraform resources into the account
- Some settings like S3 Public Access Block
- Security 

| Account    | Alias        |
|------------|--------------|
| management | 332594793360 |
| sandbox    | 854268402788 |
| staging    | 782190888228 |
| production | 671953853133 |
| security   | 103317967445 |

> Note: AWS Identity Center Permission Sets will create target roles in our accounts also, but we are not there yet! 

### The switcheroo

This account can now be swapped to use Terraform Cloud Orchestration, its configuration currently looks like this:

```hcl
provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::782190888228:role/OrganizationAccountAccessRole"
  }
}

module "core" {
  source            = "app.terraform.io/conzy-demo/modules/aws//modules/core"
  version           = "0.0.1"
  name              = "conzy-demo-staging"
  trusted_role_arns = ["arn:aws:iam::332594793360:user/terraform"]
}
```

We'll add a remote state backend and we'll modify the role used in the provider to the terraform role.

```hcl
provider "aws" {
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::782190888228:role/terraform"
  }
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "conzy-demo"
    workspaces {
      name = "staging_core"
    }
  }
}

module "core" {
  source            = "app.terraform.io/conzy-demo/modules/aws//modules/core"
  version           = "0.0.1"
  name              = "conzy-demo-staging"
  trusted_role_arns = ["arn:aws:iam::332594793360:user/terraform"]
}
```

We've made a backend change so we must run `terraform init`. Terraform will ask if we want to migrate our
local state to Terraform Cloud. We do so we answer `yes`

```
Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "remote" backend. No existing state was found in the newly
  configured "remote" backend. Do you want to copy this state to the new "remote"
  backend? Enter "yes" to copy and "no" to start with an empty state.
```

Attempting a `terraform apply` now results in a slap on the wrist.


```
│ Error: Apply not allowed for workspaces with a VCS connection
│
│ A workspace that is connected to a VCS requires the VCS-driven workflow to ensure that the VCS remains the single source of truth.
```

Where did this workspace come from? We created it in our `terraform-demo/terraform_cloud/` workspace

```hcl
module "staging_core" {
  source            = "app.terraform.io/conzy-demo/modules/tfe//modules/workspace"
  version           = "0.0.1"
  slack_webhook_url = var.slack_webhook_url
  name              = "staging_core"
  terraform_version = "1.3.9"
  organization      = tfe_organization.organization.id
  teams             = {}
  vcs_repo = {
    identifier     = "conzy/terraform-demo"
    oauth_token_id = local.oauth_token_id
    branch         = "main"
  }
  variable_sets = [
    tfe_variable_set.aws_iam_user.id
  ]
  working_directory = "aws/staging/core"
  tag_names         = ["aws", "conzy-demo-staging"]
  description       = "This workspace manages state for staging core infra."
}

```

So based on the configuration above. We should see a speculative plan on our Pull Request when terraform code in
`aws/staging/core` changes. Lets push a change and took a look.

## DNS Fun

My DNS happens to be with Cloudflare. But this is another nice opportunity to demo the power of terraform.

We are going to setup Zone Delegation. i.e I can create a subdomain for each of

- sandbox
- staging
- production

I can create Route53 Zones in each AWS account. I can then create `NS` records such as `sandbox.conormaher.com` in
Cloudflare which will then delegate all DNS resolution to Route53. This is really powerful because it allows us to 
give each account real DNS that resolves. This means when you are developing terraform against a sandbox
environment you can create DNS records to validate ACM certificates etc. And you don't need to bug your friendly
Cloud Infrastructure Engineer or risk messing with production DNS.

# SSO / AWS Identity Center

This requires one tiny Click Ops step which is just to click `Enable` in the [Identity Center Console](https://eu-west-1.console.aws.amazon.com/singlesignon/home?region=eu-west-1#!/)

The `data "aws_ssoadmin_instances" "this" {}` data source can be used to retreive info and we can use other terraform resources to manage
users, groups, permissions sets etc. It would be nice if we could also turn it on with a terraform resources but perhaps its not exposed in an api yet.

> Two other click ops changes here. Changed the vanity URL you login at. Changed the config so MFA is required and prompts you during onboarding.

Now that we have terraformed this to the point we have a user, some group membership and permission sets deployed we can login, add MFA and stop using IAM Access

## Using SSO for Programattic Access

I use [aws-vault](https://github.com/99designs/aws-vault) for prograttic access locally, there are lots of great solutions out there like [granted](https://github.com/common-fate/granted) but I am used to aws-vault and I still interact with some accounts using IAM users (boo!)

To use SSO with aws-vault you can just add a profile like this to your `~/.aws/config`

```
[profile demo-prod-view]
sso_start_url=https://conzy-demo.awsapps.com/start
sso_region=eu-west-1
sso_account_id=671953853133
sso_role_name=view_only
```

Note how this is a view only role. It makes sense to operate as safe roles and only elevate your priviliges when absolutely neccessary. All changes should be via Terraform Cloud. For safety even though I would typically have access to highly privilged roles I will comment them out or remove them from my profile to avoid accidental usage!

# Security Account and Security Services

Created many [helper modules](https://github.com/conzy/terraform-aws-modules/pull/2) for the management account and security
account that enabled:

- Cloudtrail Organisation Trail
- AWS Config
- AWS Config Aggregator
- AWS GuardDuty
- AWS Security Hub

Added to our `core` module which is deployed in each account to add AWS Config to the other sensible defaults.

## Billing

The root account and some Click Ops is required to enable billing access. I then created a permission set that allows
access to billing in the management account. I strongly believe _everyone_ should have access to AWS Cost Explorer. In
the new serverless paradigm, technical and business decisions can have huge impact on the AWS bill, its important that
every engineer is empowered to see the impact their technical decisions have on the cost, the AWS bill should not be a secret.
I have found giving finance teams access to the billing Console also makes their lives easier.
