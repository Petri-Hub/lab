variable "tailscale_oauth_client_id" {
  description = "Tailscale OAuth Client ID"
  type        = string
  sensitive   = true
}

variable "tailscale_oauth_client_secret" {
  description = "Tailscale OAuth Client Secret"
  type        = string
  sensitive   = true
}

variable "tailscale_tailnet" {
  description = "The name of the Tailscale tailnet to manage"
  type        = string
}

variable "infra_portainer_port" {
  description = "The Portainer UI port"
  type        = number
}

variable "infra_glances_port" {
  description = "Glances UI port"
  type        = number
}

variable "infra_satisfactory_port" {
  description = "Satisfactory game server port"
  type        = number
}