locals {
  tunnel_secret = base64encode(var.cloudflare_account_id)
}