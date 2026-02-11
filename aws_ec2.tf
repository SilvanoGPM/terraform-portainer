resource "aws_instance" "docker_swarm_manager_primary" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  subnet_id              = aws_default_subnet.default_az1.id
  key_name               = "${var.project_name}-key"
}

resource "null_resource" "docker_swarm_manager_primary_setup" {
  connection {
    type        = "ssh"
    user        = var.aws_default_user
    host        = aws_instance.docker_swarm_manager_primary.public_ip
    private_key = file("${var.aws_ssh_private_key_path}")
  }

  provisioner "file" {
    content = templatefile("${path.module}/stacks/infra-stack.yaml.tpl", {
      domain             = var.domain,
      lets_encrypt_email = var.lets_encrypt_email,
      traefik_user       = var.traefik_user,
      environment        = var.environment
    })
    destination = "/home/${var.aws_default_user}/infra-stack.yaml"
  }

  provisioner "file" {
    source      = "./scripts/install-portainer.sh"
    destination = "/home/${var.aws_default_user}/install-portainer.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/${var.aws_default_user}/install-portainer.sh",
      "sudo sh /home/${var.aws_default_user}/install-portainer.sh >> /home/${var.aws_default_user}/install-portainer.log 2>&1",
      "sudo docker swarm join-token -q manager > manager_token",
      "sudo docker swarm join-token -q worker > worker_token"
    ]
  }

  depends_on = [aws_instance.docker_swarm_manager_primary]
}

resource "aws_instance" "swarm_managers" {
  count = var.docker_swarm_manager_count - 1

  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  subnet_id              = aws_default_subnet.default_az1.id
  key_name               = "${var.project_name}-key"
}

resource "null_resource" "manager_join" {
  count = var.docker_swarm_manager_count - 1

  connection {
    type        = "ssh"
    user        = var.aws_default_user
    host        = aws_instance.swarm_managers[count.index].public_ip
    private_key = file(var.aws_ssh_private_key_path)
  }

  provisioner "file" {
    source      = var.aws_ssh_private_key_path
    destination = "/home/${var.aws_default_user}/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /home/${var.aws_default_user}/.ssh/id_rsa",

      "sudo apt update -y && sudo apt install -y docker.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      # pegar token do manager primário
      "TOKEN=$(sudo ssh -i /home/${var.aws_default_user}/.ssh/id_rsa -o StrictHostKeyChecking=no ${var.aws_default_user}@${aws_instance.docker_swarm_manager_primary.public_ip} 'cat manager_token')",

      "sudo docker swarm join --token $TOKEN ${aws_instance.docker_swarm_manager_primary.private_ip}:2377"
    ]
  }

  depends_on = [null_resource.docker_swarm_manager_primary_setup]
}

resource "aws_instance" "swarm_workers" {
  count = var.docker_swarm_worker_count

  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  subnet_id              = aws_default_subnet.default_az1.id
  key_name               = "${var.project_name}-key"
}

resource "null_resource" "worker_join" {
  count = var.docker_swarm_worker_count

  connection {
    type        = "ssh"
    user        = var.aws_default_user
    host        = aws_instance.swarm_workers[count.index].public_ip
    private_key = file(var.aws_ssh_private_key_path)
  }

  provisioner "file" {
    source      = var.aws_ssh_private_key_path
    destination = "/home/${var.aws_default_user}/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /home/${var.aws_default_user}/.ssh/id_rsa",

      "sudo apt update -y && sudo apt install -y docker.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      "TOKEN=$(sudo ssh -i /home/${var.aws_default_user}/.ssh/id_rsa -o StrictHostKeyChecking=no ${var.aws_default_user}@${aws_instance.docker_swarm_manager_primary.public_ip} 'cat worker_token')",

      "sudo docker swarm join --token $TOKEN ${aws_instance.docker_swarm_manager_primary.private_ip}:2377"
    ]
  }

  depends_on = [null_resource.docker_swarm_manager_primary_setup]
}
