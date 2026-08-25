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
          "tag:lab:${var.ports.palworld}",
          "tag:lab:${var.ports.teamspeak.voice}",
          "tag:lab:${var.ports.teamspeak.file_transfer}",
          "tag:lab:${var.ports.dst.master}",
          "tag:lab:${var.ports.dst.caves}",
          "tag:lab:${var.ports.dst.steam_1}",
          "tag:lab:${var.ports.dst.steam_2}",
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
        src    = ["tag:workstation"]
        dst    = ["tag:workstation:*"]
      },
      {
        action = "accept"
        src    = ["autogroup:shared"]
        dst = [
          "tag:lab:${var.ports.dozzle}",
          "tag:lab:${var.ports.satisfactory.game}",
          "tag:lab:${var.ports.satisfactory.messaging}",
          "tag:lab:${var.ports.palworld}",
          "tag:lab:${var.ports.teamspeak.voice}",
          "tag:lab:${var.ports.teamspeak.file_transfer}",
          "tag:lab:${var.ports.dst.master}",
          "tag:lab:${var.ports.dst.caves}",
          "tag:lab:${var.ports.dst.steam_1}",
          "tag:lab:${var.ports.dst.steam_2}"
        ]
      }
    ]
  })
}

resource "tailscale_service" "dozzle" {
  depends_on = [tailscale_acl.main]
  name       = "svc:dozzle"
  comment    = "Dozzle log viewer"
  ports      = ["tcp:${var.ports.dozzle}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "btop" {
  depends_on = [tailscale_acl.main]
  name       = "svc:btop"
  comment    = "btop system monitor"
  ports      = ["tcp:${var.ports.btop}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "filebrowser" {
  depends_on = [tailscale_acl.main]
  name       = "svc:filebrowser"
  comment    = "FileBrowser web file manager"
  ports      = ["tcp:${var.ports.filebrowser}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "ytdlp" {
  depends_on = [tailscale_acl.main]
  name       = "svc:ytdlp"
  comment    = "yt-dlp web UI"
  ports      = ["tcp:${var.ports.ytdlp}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "kamiyomu" {
  depends_on = [tailscale_acl.main]
  name       = "svc:kamiyomu"
  comment    = "KamiYomu manga downloader"
  ports      = ["tcp:${var.ports.kamiyomu}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "kavita" {
  depends_on = [tailscale_acl.main]
  name       = "svc:kavita"
  comment    = "Kavita reader"
  ports      = ["tcp:${var.ports.kavita}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "hermes" {
  depends_on = [tailscale_acl.main]
  name       = "svc:hermes"
  comment    = "Hermes agent dashboard"
  ports      = ["tcp:${var.ports.hermes}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "upsnap" {
  depends_on = [tailscale_acl.main]
  name       = "svc:upsnap"
  comment    = "UpSnap wake-on-LAN UI"
  ports      = ["tcp:${var.ports.upsnap}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "satisfactory_query" {
  depends_on = [tailscale_acl.main]
  name       = "svc:satisfactory-query"
  comment    = "Satisfactory server messaging port"
  ports      = ["tcp:${var.ports.satisfactory.messaging}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "teamspeak_file_transfer" {
  depends_on = [tailscale_acl.main]
  name       = "svc:teamspeak-filetransfer"
  comment    = "TeamSpeak file transfer port"
  ports      = ["tcp:${var.ports.teamspeak.file_transfer}"]
  tags       = ["tag:lab"]
}

resource "tailscale_service" "teamspeak_admin" {
  depends_on = [tailscale_acl.main]
  name       = "svc:teamspeak-admin"
  comment    = "TeamSpeak HTTP query/admin port (owner-only)"
  ports      = ["tcp:${var.ports.teamspeak.query_http}"]
  tags       = ["tag:lab"]
}
