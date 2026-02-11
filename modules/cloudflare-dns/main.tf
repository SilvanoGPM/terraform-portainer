resource "cloudflare_record" "wildcard" {
  zone_id         = var.cloudflare_zone_id
  name            = "*"
  type            = "A"
  content         = var.public_ip
  proxied         = false
  allow_overwrite = true
}
