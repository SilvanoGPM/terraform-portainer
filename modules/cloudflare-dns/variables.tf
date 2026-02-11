variable "cloudflare_api_token" {
  type        = string
  description = "Token da API do Cloudflare"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "ID da zona do Cloudflare"
  sensitive   = true
}

variable "public_ip" {
  type        = string
  description = "IP público para o registro DNS wildcard"
}
