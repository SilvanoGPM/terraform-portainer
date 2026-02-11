output "manager_primary_public_ip" {
  value = hcloud_server.docker_swarm_manager_primary.ipv4_address
}

output "manager_primary_ssh_connect" {
  value = "ssh -i ${var.hetzner_ssh_private_key_path} ${var.hetzner_default_user}@${hcloud_server.docker_swarm_manager_primary.ipv4_address}"
}

output "urls" {
  value = {
    traefik   = "https://traefik.${var.domain}"
    portainer = "https://portainer.${var.domain}"
  }
}
