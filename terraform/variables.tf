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
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for Terraform"
  type        = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type = string
  sensitive = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type = string
  sensitive = true
}

variable "tailscale_lab_device_name" {
  description = "The full domain address of Home Lab in Tailscale network."
  type        = string
}

variable "tailscale_monstrao_device_name" {
  description = "The full domain address of Monstrao in Tailscale network."
  type        = string
}

variable "tailscale_globals_device_name" {
  description = "The full domain address of Globals laptop in Tailscale network."
  type        = string
}

variable "tailscale_phone_device_name" {
  description = "The full domain address of phone in Tailscale network."
  type        = string
}

variable "infra_domain_url" {
  description = "The home lab domain URL"
  type        = string
}

variable "infra_dozzle_subdomain_url" {
  description = "The Dozzle subdomain"
  type        = string
}

variable "infra_ytdlp_subdomain_url" {
  description = "The YTDLP subdomain"
  type        = string
}

variable "infra_filebrowser_port" {
  description = "FileBrowser UI port"
  type = number
}

variable "infra_ytdlp_port" {
  description = "YTDLP Web UI port"
  type = number
}

variable "infra_satisfactory_game_port" {
  description = "Satisfactory game server port."
  type        = number
}

variable "infra_satisfactory_messaging_port" {
  description = "Satisfactory messaging server port."
  type        = number
}

variable "infra_dozzle_port" {
  description = "Dozzle UI port"
  type        = number
}

variable "infra_btop_port" {
  description = "BTOP UI port"
  type        = number
}

variable "infra_ssh_port" {
  description = "The SSH server port."
  type        = number
}

variable "infra_ngrok_url" {
  description = "The NGROK tunnel URL"
  type        = string
}

variable "infra_authorized_emails" {
  description = "List of authorized emails for lab access"
  type        = list(string)
  sensitive   = true
}
