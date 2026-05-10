variable "domain" {
  description = "Cloudflare tunnel domain"
  type = string
  sensitive = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type = string
  sensitive = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for Terraform"
  type      = string
  sensitive = true
}

variable "services" {
  description = "The lab services running"
  default = []
  type = list(object({
    domain = string
    name    = string
    service = string
  }))
}