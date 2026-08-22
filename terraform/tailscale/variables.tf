variable "ports" {
  description = "A map of service names to their respective ports."

  type = object({
    ytdlp       = number
    kamiyomu    = number
    kavita      = number
    ssh         = number
    dozzle      = number
    filebrowser = number
    btop        = number
    upsnap      = number
    hermes      = number
    palworld    = number
    satisfactory = object({
      game      = number
      messaging = number
    })
    teamspeak = object({
      voice         = number
      file_transfer = number
      query_http    = number
    })
    dst = object({
      master  = number
      caves   = number
      steam_1 = number
      steam_2 = number
    })
  })
}

variable "devices" {
  description = "A map of device names and their full domains."

  type = object({
    lab      = string
    monstrao = string
    phone    = string
    globals  = string
  })
}
