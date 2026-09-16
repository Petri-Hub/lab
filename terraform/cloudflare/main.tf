resource "cloudflare_zero_trust_tunnel_cloudflared" "lab" {
  account_id    = var.cloudflare_account_id
  name          = var.domain
  tunnel_secret = random_bytes.tunnel_secret.base64
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lab" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.lab.id

  config = {
    ingress = concat(
      [for svc in var.services : {
        hostname = svc.name
        service  = svc.service
      }],
      [{ service = "http_status:404" }]
    )
  }
}

resource "cloudflare_dns_record" "tunnel" {
  for_each = { for svc in var.services : svc.name => svc }
  zone_id  = var.cloudflare_zone_id
  name     = each.value.name
  type     = "CNAME"
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.lab.id}.cfargotunnel.com"
  proxied  = true
  ttl      = 1
}

resource "cloudflare_zone_setting" "ssl" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "ssl"
  value      = "flexible"
}

resource "cloudflare_zero_trust_access_application" "services" {
  for_each = { for svc in var.services : svc.name => svc }

  account_id       = var.cloudflare_account_id
  name             = each.value.name
  domain           = each.value.name
  type             = "self_hosted"
  session_duration = "504h"

  policies = [
    {
      name     = "Email OTP"
      decision = "allow"
      include = [
        for email in var.authorized_emails : {
          email = {
            email = email
          }
        }
      ]
    }
  ]
}

# Any service can opt individual paths out of Email OTP by setting bypass_paths
# on its `services` entry (e.g. a service's own API, gated by its own API key,
# reached by CLI clients that can't complete an interactive Email OTP login).
# The dashboard itself stays behind Email OTP via the generic `services` loop
# above regardless. This module stays agnostic of which service is doing it.
# NOTE: verify the exact path-scoping syntax (`domain` with a path suffix vs a
# `destinations` block) against the provider version pinned in providers.tf.
locals {
  bypass_rules = merge([
    for svc in var.services : {
      for path in svc.bypass_paths : "${svc.name}${path}" => {
        hostname = svc.name
        path     = path
      }
    }
  ]...)
}

resource "cloudflare_zero_trust_access_application" "bypass" {
  for_each = local.bypass_rules

  account_id       = var.cloudflare_account_id
  name             = "${each.value.hostname} bypass (${each.value.path})"
  domain           = "${each.value.hostname}${each.value.path}"
  type             = "self_hosted"
  session_duration = "24h"

  policies = [
    {
      name     = "Bypass"
      decision = "bypass"
      include = [
        { everyone = {} }
      ]
    }
  ]
}