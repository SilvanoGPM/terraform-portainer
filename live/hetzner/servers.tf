# ========================
# Manager Primário
# ========================

resource "hcloud_server" "docker_swarm_manager_primary" {
  name         = "${var.project_name}-manager-primary"
  server_type  = var.hetzner_server_type
  location     = var.hetzner_location
  image        = var.hetzner_image
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.docker_fw.id]

  labels = {
    project = var.project_name
    role    = "manager"
  }
}

# ========================
# Managers Adicionais
# ========================

resource "hcloud_server" "swarm_managers" {
  count        = var.docker_swarm_manager_count - 1
  name         = "${var.project_name}-manager-${count.index + 1}"
  server_type  = var.hetzner_server_type
  location     = var.hetzner_location
  image        = var.hetzner_image
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.docker_fw.id]

  labels = {
    project = var.project_name
    role    = "manager"
  }
}

# ========================
# Workers
# ========================

resource "hcloud_server" "swarm_workers" {
  count        = var.docker_swarm_worker_count
  name         = "${var.project_name}-worker-${count.index}"
  server_type  = var.hetzner_server_type
  location     = var.hetzner_location
  image        = var.hetzner_image
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.docker_fw.id]

  labels = {
    project = var.project_name
    role    = "worker"
  }
}
