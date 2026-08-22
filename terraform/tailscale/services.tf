# Tailscale Services (VIP Services) give the web/admin surfaces a stable
# svc:<name> MagicDNS name instead of raw tag:lab:<port> access, without
# needing a node to be reachable by every other node. As of provider
# v0.29.x, Services only support the `tcp` protocol, so none of the UDP
# game/voice ports (Satisfactory, Palworld, TeamSpeak voice, DST) can move
# here — those stay on the port-based ACL entries in main.tf.
#
# Declaring a Service here only registers its name/ports/tags in the
# tailnet policy. A device still has to be told to host it, which the
# provider does not manage yet: run `make tailscale-serve` on the lab
# host (see scripts/tailscale-serve.sh) to advertise each one via
# `tailscale serve`.

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

# Owner-only: the query/admin port stays loopback-bound in Docker. This
# Service exists so the owner can reach it over Tailscale instead of
# SSH-tunneling in, once advertised and granted to tag:workstation/tag:edge
# only — never add this one to the shared/friends ACL entries.
resource "tailscale_service" "teamspeak_admin" {
  depends_on = [tailscale_acl.main]
  name       = "svc:teamspeak-admin"
  comment    = "TeamSpeak HTTP query/admin port (owner-only)"
  ports      = ["tcp:${var.ports.teamspeak.query_http}"]
  tags       = ["tag:lab"]
}
