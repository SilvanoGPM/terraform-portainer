output "manager_primary_public_ip" {
  value = aws_instance.docker_swarm_manager_primary.public_ip
}

output "manager_primary_ssh_connect" {
  value = "ssh -i ${var.aws_ssh_private_key_path} ${var.aws_default_user}@${aws_instance.docker_swarm_manager_primary.public_ip}"
}

output "urls" {
  value = {
    traefik   = "https://traefik.${var.domain}"
    portainer = "https://portainer.${var.domain}"
  }
}
