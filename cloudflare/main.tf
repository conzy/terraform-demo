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

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "conzy-demo"
    workspaces {
      name = "cloudflare"
    }
  }
}

data "cloudflare_zone" "conormaher_com" {
  name = "conormaher.com"
}

resource "cloudflare_record" "ping" {
  zone_id = data.cloudflare_zone.conormaher_com.id
  name    = "ping"
  value   = "pong"
  type    = "TXT"
  ttl     = 60 # Low for demo purposes
}

