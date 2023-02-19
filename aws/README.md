# AWS

Every subdirectory here represents a collection of AWS resources deployed against a target AWS account. Each directory is
managed by a Terraform Cloud workspace. Those workspaces are defined in [terraform_cloud](../terraform_cloud)

There is a very flat access structure in this demo. In a professional environment you would map access of various
teams to each workspace using the principle of least privilege, e.g staging workspaces could be triggered by a larger group
than production workspaces, staging workspaces might auto apply with production workspaces needing manual approval.
Management account and security workspaces locked down to a core infra or security team etc.
