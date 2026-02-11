resource "cloudflare_record" "wildcard" {
  count = var.cloudflare_api_token != null ? 1 : 0 # Só cria o registro se o token do Cloudflare for fornecido

  zone_id         = var.cloudflare_zone_id
  name            = "*" # Registro curinga para o domínio, apontando para o IP público da instância, permitindo que subdomínios sejam resolvidos corretamente.
  type            = "A"
  content         = local.primary_public_ip
  proxied         = false
  allow_overwrite = true
}
