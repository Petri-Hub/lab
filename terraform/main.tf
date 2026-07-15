module "tailscale" {
  source = "./tailscale"

  ports = {
    ytdlp       = var.infra_ytdlp_port
    kamiyomu    = var.infra_kamiyomu_port
    ssh         = var.infra_ssh_port
    dozzle      = var.infra_dozzle_port
    filebrowser = var.infra_filebrowser_port
    btop        = var.infra_btop_port
    upsnap      = var.infra_upsnap_port
    hermes      = var.infra_hermes_dashboard_port
    satisfactory = {
      game      = var.infra_satisfactory_game_port
      messaging = var.infra_satisfactory_messaging_port
    }
  }

  devices = {
    lab      = var.tailscale_lab_device_name
    monstrao = var.tailscale_monstrao_device_name
    phone    = var.tailscale_phone_device_name
    globals  = var.tailscale_globals_device_name
  }

  providers = {
    tailscale = tailscale
  }
}

module "cloudflare" {
  source = "./cloudflare"

  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_zone_id    = var.cloudflare_zone_id
  cloudflare_api_token  = var.cloudflare_api_token

  domain            = var.infra_domain_url
  authorized_emails = var.infra_authorized_emails

  services = [
    {
      domain  = var.infra_domain_url
      name    = "${var.infra_dozzle_subdomain_url}.${var.infra_domain_url}"
      service = "http://nginx:80"
    },
    {
      domain  = var.infra_domain_url
      name    = "${var.infra_ytdlp_subdomain_url}.${var.infra_domain_url}"
      service = "http://nginx:80"
    },
    {
      domain  = var.infra_domain_url
      name    = "${var.infra_kamiyomu_subdomain_url}.${var.infra_domain_url}"
      service = "http://nginx:80"
    },
    {
      domain  = var.infra_domain_url
      name    = "${var.infra_btop_subdomain_url}.${var.infra_domain_url}"
      service = "http://nginx:80"
    },
    {
      domain  = var.infra_domain_url
      name    = "${var.infra_upsnap_subdomain_url}.${var.infra_domain_url}"
      service = "http://nginx:80"
    }
  ]
}
