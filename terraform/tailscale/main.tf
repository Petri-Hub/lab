data "tailscale_device" "lab" {
  name     = var.devices.lab
  wait_for = "60s"
}

data "tailscale_device" "monstrao" {
  name     = var.devices.monstrao
  wait_for = "60s"
}

data "tailscale_device" "phone" {
  name     = var.devices.phone
  wait_for = "60s"
}

data "tailscale_device" "globals" {
  name     = var.devices.globals
  wait_for = "60s"
}

resource "tailscale_device_tags" "lab" {
  depends_on = [tailscale_acl.main]
  device_id  = data.tailscale_device.lab.node_id
  tags       = ["tag:lab"]
}

resource "tailscale_device_tags" "monstrao" {
  depends_on = [tailscale_acl.main]
  device_id  = data.tailscale_device.monstrao.node_id
  tags       = ["tag:edge"]
}

resource "tailscale_device_tags" "phone" {
  depends_on = [tailscale_acl.main]
  device_id  = data.tailscale_device.phone.node_id
  tags       = ["tag:edge"]
}

resource "tailscale_device_tags" "globals" {
  depends_on = [tailscale_acl.main]
  device_id  = data.tailscale_device.globals.node_id
  tags       = ["tag:edge"]
}

resource "tailscale_acl" "main" {
  acl = jsonencode({
    tagOwners = {
      "tag:lab"  = ["autogroup:owner"]
      "tag:edge" = ["autogroup:owner"]
    }

    acls = [
      {
        action = "accept"
        src    = ["autogroup:owner"]
        dst    = ["*:*"]
      },
      {
        action = "accept"
        src    = ["tag:edge"]
        dst = [
          "tag:lab:${var.ports.portainer}",
          "tag:lab:${var.ports.glances}",
          "tag:lab:${var.ports.satisfactory}",
          "tag:lab:${var.ports.ssh}"
        ]
      },
    ]
  })
}
