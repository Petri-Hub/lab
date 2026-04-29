variable "tailscale_oauth_client_id" {
  description = "Tailscale OAuth Client ID."
  type        = string
  sensitive   = true
}

variable "tailscale_oauth_client_secret" {
  description = "Tailscale OAuth Client Secret."
  type        = string
  sensitive   = true
}

variable "tailscale_tailnet" {
  description = "The name of the Tailscale tailnet to manage."
  type        = string
}

variable "tailscale_lab_device_name" {
  description = "The full domain address of Home Lab in Tailscale network."
  type = string
}

variable "tailscale_monstrao_device_name" {
  description = "The full domain address of Monstrao in Tailscale network."
  type = string
}

variable "tailscale_globals_device_name" {
  description = "The full domain address of Globals laptop in Tailscale network."
  type = string
}

variable "tailscale_phone_device_name" {
  description = "The full domain address of phone in Tailscale network."
  type = string
}

variable "infra_portainer_port" {
  description = "The Portainer UI port."
  type        = number
}

variable "infra_glances_port" {
  description = "Glances UI port."
  type        = number
}

variable "infra_satisfactory_port" {
  description = "Satisfactory game server port."
  type        = number
}

variable "infra_ssh_port" {
  description = "The SSH server port."
  type        = number
}