# Cloudflare / Route53

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

