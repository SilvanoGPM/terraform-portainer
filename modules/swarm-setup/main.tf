locals {
  # replace(): normaliza CRLF -> LF (working copy no Windows)
  install_script = replace(file("${var.scripts_path}/install-portainer.sh"), "\r\n", "\n")

  infra_stack = replace(templatefile("${var.stacks_path}/infra-stack.yaml.tpl", {
    domain             = var.domain
    lets_encrypt_email = var.lets_encrypt_email
    traefik_user       = replace(var.traefik_user, "$", "$$")
    environment        = var.environment
  }), "\r\n", "\n")
}

# ========================
# Manager Primário - Setup
# ========================

resource "null_resource" "primary_setup" {
  # Sem triggers o provisionamento so roda na criacao do recurso: mudancas no
  # script ou no stack nunca chegariam ao servidor num apply subsequente.
  triggers = {
    install_script = sha256(local.install_script)
    infra_stack    = sha256(local.infra_stack)
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.primary_public_ip
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content     = local.infra_stack
    destination = "${var.home_dir}/infra-stack.yaml"
  }

  provisioner "file" {
    content     = local.install_script
    destination = "${var.home_dir}/install-portainer.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      # rede de seguranca: remove CR caso algum arquivo chegue com CRLF
      "${var.sudo_prefix}sed -i 's/\\r$//' ${var.home_dir}/install-portainer.sh ${var.home_dir}/infra-stack.yaml",
      "${var.sudo_prefix}chmod +x ${var.home_dir}/install-portainer.sh",
      "${var.sudo_prefix}bash ${var.home_dir}/install-portainer.sh",
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
      "set -e",
      "${var.sudo_prefix}chmod 400 ${var.home_dir}/.ssh/id_rsa",

      "command -v cloud-init >/dev/null 2>&1 && ${var.sudo_prefix}cloud-init status --wait || true",
      "export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a",
      "${var.sudo_prefix}apt-get -o DPkg::Lock::Timeout=600 update -y",
      "${var.sudo_prefix}apt-get -o DPkg::Lock::Timeout=600 install -y docker.io",
      "${var.sudo_prefix}systemctl enable --now docker",

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
      "set -e",
      "${var.sudo_prefix}chmod 400 ${var.home_dir}/.ssh/id_rsa",

      "command -v cloud-init >/dev/null 2>&1 && ${var.sudo_prefix}cloud-init status --wait || true",
      "export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a",
      "${var.sudo_prefix}apt-get -o DPkg::Lock::Timeout=600 update -y",
      "${var.sudo_prefix}apt-get -o DPkg::Lock::Timeout=600 install -y docker.io",
      "${var.sudo_prefix}systemctl enable --now docker",

      "TOKEN=$(${var.sudo_prefix}ssh -i ${var.home_dir}/.ssh/id_rsa -o StrictHostKeyChecking=no ${var.ssh_user}@${var.primary_public_ip} 'cat ${var.home_dir}/worker_token')",

      "${var.sudo_prefix}docker swarm join --token $TOKEN ${var.swarm_join_ip}:2377"
    ]
  }

  depends_on = [null_resource.primary_setup]
}
