output "cloud_provider" {
  value = var.cloud_provider
}

output "manager_primary_public_ip" {
  value = local.primary_public_ip
}

output "manager_primary_ssh_connect" {
  value = "ssh -i ${local.ssh_private_key_path} ${local.ssh_user}@${local.primary_public_ip}"
}

output "urls" {
  value = {
    traefik   = "https://traefik.${var.domain}",
    portainer = "https://portainer.${var.domain}"
  }
}
