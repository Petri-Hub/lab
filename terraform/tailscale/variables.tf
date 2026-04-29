variable "ports" {
  description = "A map of service names to their respective ports."

  type = object({
    portainer    = number
    glances      = number
    satisfactory = number
    ssh = string
  })
}

variable "devices" {
  description = "A map of device names and their full domains."

  type = object({
    lab = string
    monstrao = string
    phone = string
    globals = string
  })
}