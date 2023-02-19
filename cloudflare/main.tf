terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "conormaher_com" {
  name = "conormaher.com"
}

# Get the name servers I need from remote state?

resource "cloudflare_record" "ping" {
  zone_id = data.cloudflare_zone.conormaher_com.id
  name    = "ping"
  value   = "pong"
  type    = "TXT"
  ttl     = 60 # Low for demo purposes
}

# Delegate DNS Zones

locals {
  sandbox_ns = [
    "ns-1050.awsdns-03.org",
    "ns-1676.awsdns-17.co.uk",
    "ns-384.awsdns-48.com",
    "ns-797.awsdns-35.net",
  ]
}

resource "cloudflare_record" "sandbox" {
  for_each = toset(local.sandbox_ns)
  zone_id  = data.cloudflare_zone.conormaher_com.id
  name     = "sandbox"
  value    = each.key
  type     = "NS"
  ttl      = 60 # Low for demo purposes
}

