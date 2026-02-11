locals {
  sg_default_cidr = "0.0.0.0/0"

  is_aws     = var.cloud_provider == "aws"
  is_hetzner = var.cloud_provider == "hetzner"

  primary_public_ip = local.is_aws ? aws_instance.docker_swarm_manager_primary[0].public_ip : hcloud_server.docker_swarm_manager_primary[0].ipv4_address

  ssh_user             = local.is_aws ? var.aws_default_user : var.hetzner_default_user
  ssh_private_key_path = local.is_aws ? var.aws_ssh_private_key_path : var.hetzner_ssh_private_key_path
  ssh_home_dir         = local.is_aws ? "/home/${var.aws_default_user}" : "/root"
}
