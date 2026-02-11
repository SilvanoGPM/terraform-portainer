# ========================
# Manager Primário
# ========================

resource "aws_instance" "docker_swarm_manager_primary" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  subnet_id              = aws_default_subnet.default_az1.id
  key_name               = "${var.project_name}-key"
}

# ========================
# Managers Adicionais
# ========================

resource "aws_instance" "swarm_managers" {
  count = var.docker_swarm_manager_count - 1

  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  subnet_id              = aws_default_subnet.default_az1.id
  key_name               = "${var.project_name}-key"
}

# ========================
# Workers
# ========================

resource "aws_instance" "swarm_workers" {
  count = var.docker_swarm_worker_count

  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  subnet_id              = aws_default_subnet.default_az1.id
  key_name               = "${var.project_name}-key"
}
