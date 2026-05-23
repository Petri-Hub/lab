variable "ports" {
  description = "A map of service names to their respective ports."

  type = object({
    ytdlp       = number
    ssh         = number
    dozzle      = number
    filebrowser = number
    btop        = number
    upsnap      = number
    satisfactory = object({
      game      = number
      messaging = number
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
