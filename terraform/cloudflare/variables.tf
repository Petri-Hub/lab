variable "domain" {
  description = "Cloudflare tunnel domain"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for Terraform"
  type        = string
  sensitive   = true
}

variable "services" {
  description = "The lab services running"
  default     = []
  type = list(object({
    domain  = string
    name    = string
    service = string
    # Path prefixes under this service's hostname that should bypass Cloudflare
    # Access entirely (e.g. a service's own API, gated by its own API key,
    # reached by CLI clients that can't complete an interactive Email OTP login).
    bypass_paths = optional(list(string), [])
  }))
}

variable "authorized_emails" {
  description = "List of authorized email addresses for Cloudflare Access"
  type        = list(string)
  sensitive   = true
}
