resource "hcloud_ssh_key" "default" {
  count      = local.is_hetzner ? 1 : 0
  name       = "${var.project_name}-key"
  public_key = file(var.hetzner_ssh_public_key_path)
}

# ========================
# Manager Primário
# ========================

resource "hcloud_server" "docker_swarm_manager_primary" {
  count        = local.is_hetzner ? 1 : 0
  name         = "${var.project_name}-manager-primary"
  server_type  = var.hetzner_server_type
  location     = var.hetzner_location
  image        = var.hetzner_image
  ssh_keys     = [hcloud_ssh_key.default[0].id]
  firewall_ids = [hcloud_firewall.docker_fw[0].id]

  labels = {
    project = var.project_name
    role    = "manager"
  }
}

resource "null_resource" "hetzner_manager_primary_setup" {
  count = local.is_hetzner ? 1 : 0

  connection {
    type        = "ssh"
    user        = var.hetzner_default_user
    host        = hcloud_server.docker_swarm_manager_primary[0].ipv4_address
    private_key = file(var.hetzner_ssh_private_key_path)
  }

  provisioner "file" {
    content = templatefile("${path.module}/stacks/infra-stack.yaml.tpl", {
      domain             = var.domain,
      lets_encrypt_email = var.lets_encrypt_email,
      traefik_user       = var.traefik_user,
      environment        = var.environment
    })
    destination = "/root/infra-stack.yaml"
  }

  provisioner "file" {
    source      = "./scripts/install-portainer.sh"
    destination = "/root/install-portainer.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/install-portainer.sh",
      "sh /root/install-portainer.sh >> /root/install-portainer.log 2>&1",
      "docker swarm join-token -q manager > /root/manager_token",
      "docker swarm join-token -q worker > /root/worker_token"
    ]
  }

  depends_on = [hcloud_server.docker_swarm_manager_primary]
}

# ========================
# Managers Adicionais
# ========================

resource "hcloud_server" "swarm_managers" {
  count        = local.is_hetzner ? var.docker_swarm_manager_count - 1 : 0
  name         = "${var.project_name}-manager-${count.index + 1}"
  server_type  = var.hetzner_server_type
  location     = var.hetzner_location
  image        = var.hetzner_image
  ssh_keys     = [hcloud_ssh_key.default[0].id]
  firewall_ids = [hcloud_firewall.docker_fw[0].id]

  labels = {
    project = var.project_name
    role    = "manager"
  }
}

resource "null_resource" "hetzner_manager_join" {
  count = local.is_hetzner ? var.docker_swarm_manager_count - 1 : 0

  connection {
    type        = "ssh"
    user        = var.hetzner_default_user
    host        = hcloud_server.swarm_managers[count.index].ipv4_address
    private_key = file(var.hetzner_ssh_private_key_path)
  }

  provisioner "file" {
    source      = var.hetzner_ssh_private_key_path
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /root/.ssh/id_rsa",

      "apt update -y && apt install -y docker.io",
      "systemctl enable docker",
      "systemctl start docker",

      # pegar token do manager primário
      "TOKEN=$(ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no ${var.hetzner_default_user}@${hcloud_server.docker_swarm_manager_primary[0].ipv4_address} 'cat /root/manager_token')",

      "docker swarm join --token $TOKEN ${hcloud_server.docker_swarm_manager_primary[0].ipv4_address}:2377"
    ]
  }

  depends_on = [null_resource.hetzner_manager_primary_setup]
}

# ========================
# Workers
# ========================

resource "hcloud_server" "swarm_workers" {
  count        = local.is_hetzner ? var.docker_swarm_worker_count : 0
  name         = "${var.project_name}-worker-${count.index}"
  server_type  = var.hetzner_server_type
  location     = var.hetzner_location
  image        = var.hetzner_image
  ssh_keys     = [hcloud_ssh_key.default[0].id]
  firewall_ids = [hcloud_firewall.docker_fw[0].id]

  labels = {
    project = var.project_name
    role    = "worker"
  }
}

resource "null_resource" "hetzner_worker_join" {
  count = local.is_hetzner ? var.docker_swarm_worker_count : 0

  connection {
    type        = "ssh"
    user        = var.hetzner_default_user
    host        = hcloud_server.swarm_workers[count.index].ipv4_address
    private_key = file(var.hetzner_ssh_private_key_path)
  }

  provisioner "file" {
    source      = var.hetzner_ssh_private_key_path
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /root/.ssh/id_rsa",

      "apt update -y && apt install -y docker.io",
      "systemctl enable docker",
      "systemctl start docker",

      "TOKEN=$(ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no ${var.hetzner_default_user}@${hcloud_server.docker_swarm_manager_primary[0].ipv4_address} 'cat /root/worker_token')",

      "docker swarm join --token $TOKEN ${hcloud_server.docker_swarm_manager_primary[0].ipv4_address}:2377"
    ]
  }

  depends_on = [null_resource.hetzner_manager_primary_setup]
}
