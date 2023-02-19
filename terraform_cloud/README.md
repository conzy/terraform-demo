# Terraform Cloud

This directory manages all Terraform Cloud configuration. i.e our entire Terraform Cloud system is managed using terraform
which is also hosted from this repo.

## Helper Modules

I have created [terraform-tfe-modules](https://github.com/conzy/terraform-tfe-modules) which is a collection of modules
that makes managing and orchestrating Terraform Cloud much simpler. 

### Workspace
The workspace module creates a workspace with:

- Team Access (in Terraform Cloud Teams / Business / Enterprise)
- VCS Configuration
- Slack Notifications
- Tagging
- Variable Set Association

### Registry

One of the powerful features of Terraform Cloud is the private module registry. Modules are just terraform code in a repo
with a particular naming structure. The registry helper module creates:

- The GitHub repo from a terraform module template repo
- Branch Protection on the repo which must pass linting.
- Registers the module with the Terraform Cloud registry

All future tags / releases on the GitHub repo create a new module version automatically.

## Workspaces

We create dozens of workspaces here, as mentioned in our [Design Principals](../README.md#blast-radius--state-isolation)
section on blast radius and state isolation, we split our workspaces to match our risk appetite.

## Registry

We create a registry module for each of our modules.
