terraform {
  required_version = ">= 1.0"

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.28.0"
    }
  }
}

provider "tailscale" {
  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
  tailnet             = var.tailscale_tailnet
}