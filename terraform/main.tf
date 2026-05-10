module "tailscale" {
  source = "./tailscale"

  ports = {
    portainer    = var.infra_portainer_port
    glances      = var.infra_glances_port
    ssh          = var.infra_ssh_port
    
    satisfactory = {
      game = var.infra_satisfactory_game_port
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
