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
  tags       = ["tag:workstation"]
}

resource "tailscale_device_tags" "globals" {
  depends_on = [tailscale_acl.main]
  device_id  = data.tailscale_device.globals.node_id
  tags       = ["tag:workstation"]
}

resource "tailscale_device_tags" "phone" {
  depends_on = [tailscale_acl.main]
  device_id  = data.tailscale_device.phone.node_id
  tags       = ["tag:edge"]
}

resource "tailscale_acl" "main" {
  acl = jsonencode({
    tagOwners = {
      "tag:lab"         = ["autogroup:owner"]
      "tag:workstation" = ["autogroup:owner"]
      "tag:edge"        = ["autogroup:owner"]
    }

    acls = [
      {
        action = "accept"
        src    = ["autogroup:owner"]
        dst    = ["*:*"]
      },
      {
        action = "accept"
        src    = ["tag:edge", "tag:workstation"]
        dst = [
          "tag:lab:${var.ports.ytdlp}",
          "tag:lab:${var.ports.kamiyomu}",
          "tag:lab:${var.ports.kavita}",
          "tag:lab:${var.ports.dozzle}",
          "tag:lab:${var.ports.btop}",
          "tag:lab:${var.ports.filebrowser}",
          "tag:lab:${var.ports.hermes}",
          "tag:lab:${var.ports.satisfactory.game}",
          "tag:lab:${var.ports.satisfactory.messaging}",
          "tag:lab:${var.ports.ssh}",
          "tag:lab:${var.ports.upsnap}"
        ]
      },
      {
        action = "accept"
        src    = ["tag:edge"]
        dst    = ["tag:workstation:*"]
      },
      {
        action = "accept"
        src    = ["autogroup:shared"]
        dst = [
          "tag:lab:${var.ports.dozzle}",
          "tag:lab:${var.ports.satisfactory.game}",
          "tag:lab:${var.ports.satisfactory.messaging}"
        ]
      }
    ]
  })
}
