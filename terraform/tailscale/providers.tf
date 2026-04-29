terraform {
  required_version = ">= 1.0"

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
    }
  }
}