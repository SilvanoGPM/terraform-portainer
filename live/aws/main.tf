provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project = var.project_name
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "swarm_setup" {
  source = "../../modules/swarm-setup"

  ssh_user             = var.aws_default_user
  ssh_private_key_path = var.aws_ssh_private_key_path
  home_dir             = "/home/${var.aws_default_user}"
  sudo_prefix          = "sudo "

  primary_public_ip = aws_instance.docker_swarm_manager_primary.public_ip
  swarm_join_ip     = aws_instance.docker_swarm_manager_primary.private_ip

  manager_public_ips = aws_instance.swarm_managers[*].public_ip
  worker_public_ips  = aws_instance.swarm_workers[*].public_ip

  domain             = var.domain
  lets_encrypt_email = var.lets_encrypt_email
  traefik_user       = var.traefik_user
  environment        = var.environment

  scripts_path = "${path.module}/../../scripts"
  stacks_path  = "${path.module}/../../stacks"

  depends_on = [aws_instance.docker_swarm_manager_primary]
}

module "cloudflare_dns" {
  count  = var.cloudflare_api_token != null ? 1 : 0
  source = "../../modules/cloudflare-dns"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  public_ip            = aws_instance.docker_swarm_manager_primary.public_ip

  depends_on = [module.swarm_setup]
}
