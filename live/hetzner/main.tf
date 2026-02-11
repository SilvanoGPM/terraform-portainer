provider "hcloud" {
  token = var.hetzner_api_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "swarm_setup" {
  source = "../../modules/swarm-setup"

  ssh_user             = var.hetzner_default_user
  ssh_private_key_path = var.hetzner_ssh_private_key_path
  home_dir             = "/root"
  sudo_prefix          = ""

  primary_public_ip = hcloud_server.docker_swarm_manager_primary.ipv4_address
  swarm_join_ip     = hcloud_server.docker_swarm_manager_primary.ipv4_address

  manager_public_ips = hcloud_server.swarm_managers[*].ipv4_address
  worker_public_ips  = hcloud_server.swarm_workers[*].ipv4_address

  domain             = var.domain
  lets_encrypt_email = var.lets_encrypt_email
  traefik_user       = var.traefik_user
  environment        = var.environment

  scripts_path = "${path.module}/../../scripts"
  stacks_path  = "${path.module}/../../stacks"

  depends_on = [hcloud_server.docker_swarm_manager_primary]
}

module "cloudflare_dns" {
  count  = var.cloudflare_api_token != null ? 1 : 0
  source = "../../modules/cloudflare-dns"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  public_ip            = hcloud_server.docker_swarm_manager_primary.ipv4_address

  depends_on = [module.swarm_setup]
}
