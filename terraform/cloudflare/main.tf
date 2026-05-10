resource "cloudflare_zero_trust_tunnel_cloudflared" "lab" {
  account_id    = var.cloudflare_account_id
  name          = var.domain
  tunnel_secret = local.tunnel_secret
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
  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lab.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}