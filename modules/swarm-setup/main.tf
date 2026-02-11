# ========================
# Manager Primário - Setup
# ========================

resource "null_resource" "primary_setup" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.primary_public_ip
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content = templatefile("${var.stacks_path}/infra-stack.yaml.tpl", {
      domain             = var.domain
      lets_encrypt_email = var.lets_encrypt_email
      traefik_user       = replace(var.traefik_user, "$", "$$")
      environment        = var.environment
    })
    destination = "${var.home_dir}/infra-stack.yaml"
  }

  provisioner "file" {
    source      = "${var.scripts_path}/install-portainer.sh"
    destination = "${var.home_dir}/install-portainer.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.sudo_prefix}chmod +x ${var.home_dir}/install-portainer.sh",
      "${var.sudo_prefix}sh ${var.home_dir}/install-portainer.sh >> ${var.home_dir}/install-portainer.log 2>&1",
      "${var.sudo_prefix}docker swarm join-token -q manager > ${var.home_dir}/manager_token",
      "${var.sudo_prefix}docker swarm join-token -q worker > ${var.home_dir}/worker_token"
    ]
  }
}

# ========================
# Managers Adicionais - Join
# ========================

resource "null_resource" "manager_join" {
  count = length(var.manager_public_ips)

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.manager_public_ips[count.index]
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = var.ssh_private_key_path
    destination = "${var.home_dir}/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.sudo_prefix}chmod 400 ${var.home_dir}/.ssh/id_rsa",

      "${var.sudo_prefix}apt update -y && ${var.sudo_prefix}apt install -y docker.io",
      "${var.sudo_prefix}systemctl enable docker",
      "${var.sudo_prefix}systemctl start docker",

      "TOKEN=$(${var.sudo_prefix}ssh -i ${var.home_dir}/.ssh/id_rsa -o StrictHostKeyChecking=no ${var.ssh_user}@${var.primary_public_ip} 'cat ${var.home_dir}/manager_token')",

      "${var.sudo_prefix}docker swarm join --token $TOKEN ${var.swarm_join_ip}:2377"
    ]
  }

  depends_on = [null_resource.primary_setup]
}

# ========================
# Workers - Join
# ========================

resource "null_resource" "worker_join" {
  count = length(var.worker_public_ips)

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.worker_public_ips[count.index]
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = var.ssh_private_key_path
    destination = "${var.home_dir}/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.sudo_prefix}chmod 400 ${var.home_dir}/.ssh/id_rsa",

      "${var.sudo_prefix}apt update -y && ${var.sudo_prefix}apt install -y docker.io",
      "${var.sudo_prefix}systemctl enable docker",
      "${var.sudo_prefix}systemctl start docker",

      "TOKEN=$(${var.sudo_prefix}ssh -i ${var.home_dir}/.ssh/id_rsa -o StrictHostKeyChecking=no ${var.ssh_user}@${var.primary_public_ip} 'cat ${var.home_dir}/worker_token')",

      "${var.sudo_prefix}docker swarm join --token $TOKEN ${var.swarm_join_ip}:2377"
    ]
  }

  depends_on = [null_resource.primary_setup]
}
