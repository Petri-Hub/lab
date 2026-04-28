resource "tailscale_device_tags" "petri_lab" {
  device_id = data.tailscale_device.petri_lab.node_id
  tags = [
    "tag:gameserver",
    "tag:homelab"
  ]
}

resource "tailscale_acl" "main" {
  acl = jsonencode({
    tagOwners = {
      "tag:gameserver" = ["autogroup:owner"]
      "tag:homelab"    = ["autogroup:owner"]
    }

    acls = [
      {
        action = "accept"
        src    = ["autogroup:owner"]
        dst    = ["*:*"]
      },
      {
        action = "accept"
        src    = ["autogroup:member"]
        dst    = [
          "tag:homelab:${var.infra_portainer_port}",
          "tag:homelab:${var.infra_glances_port}"
        ]
      },
      {
        action = "accept"
        src    = ["autogroup:shared"]
        dst    = ["tag:gameserver:${var.infra_satisfactory_port}"]
      }
    ]

    grants = [
      {
        src = ["autogroup:owner"]
        dst = ["tag:homelab"]
        ip  = ["*"]
      },
      {
        src = ["autogroup:member"]
        dst = ["svc:portainer", "svc:glances"]
        ip  = ["tcp:443"]
      }
    ]
  })
}

resource "tailscale_dns_configuration" "main" {
  magic_dns = true

  nameservers {
    address = "1.1.1.1"
  }

  nameservers {
    address = "8.8.8.8"
  }
}