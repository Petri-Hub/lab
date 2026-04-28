module "tailscale" {
  source            = "./tailscale"
  ports = {
    portainer    = var.infra_portainer_port
    glances      = var.infra_glances_port
    satisfactory = var.infra_satisfactory_port
  }
}