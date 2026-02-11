resource "hcloud_firewall" "docker_fw" {
  count = local.is_hetzner ? 1 : 0
  name  = "${var.project_name}-docker-swarm-fw"

  rule {
    description = "Permitir acesso HTTP"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Permitir acesso HTTPS"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Permitir acesso SSH"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Permitir acesso ao Portainer"
    direction   = "in"
    protocol    = "tcp"
    port        = "9000"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Permitir trafego de gerenciamento do Docker Swarm"
    direction   = "in"
    protocol    = "tcp"
    port        = "2377"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Permitir trafego da rede overlay do Docker Swarm"
    direction   = "in"
    protocol    = "udp"
    port        = "4789"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Permitir comunicacao entre nos do Docker Swarm TCP"
    direction   = "in"
    protocol    = "tcp"
    port        = "7946"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Permitir comunicacao entre nos do Docker Swarm UDP"
    direction   = "in"
    protocol    = "udp"
    port        = "7946"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  labels = {
    project = var.project_name
  }
}
