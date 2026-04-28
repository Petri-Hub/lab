variable "ports" {
  description = "A map of service names to their respective ports"
  type = object({
    portainer    = number
    glances      = number
    satisfactory = number
  })
  default = {
    portainer    = 9000
    glances      = 61208
    satisfactory = 7777
  }
}
