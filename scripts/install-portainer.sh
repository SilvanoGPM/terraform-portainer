#!/bin/bash

echo "=== Atualizando o sistema ==="
sudo apt update -y
sudo apt upgrade -y

echo "=== Instalando o Docker ==="
sudo apt install -y docker.io curl

echo "=== Habilitando e iniciando o Docker ==="
sudo systemctl enable docker
sudo systemctl start docker

echo "=== Adicionando usuário ao grupo docker ==="
sudo usermod -aG docker ubuntu || true
sudo usermod -aG docker $USER || true

echo "=== Obtendo IP privado ==="
PRIVATE_IP=$(curl -sf http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null || hostname -I | awk '{print $1}')

echo "IP privado detectado: $PRIVATE_IP"

echo "=== Inicializando Docker Swarm ==="
sudo docker swarm init --advertise-addr "$PRIVATE_IP" || true

echo ""
echo "=== Status do Swarm ==="
sudo docker node ls || true

echo ""
echo "=== Criando redes Docker ==="
sudo docker network create -d overlay traefik-public || true
sudo docker network create -d overlay portainer-agent || true

echo ""
echo "=== Deploy do Portainer e Traefik ==="
sudo docker stack deploy -c infra-stack.yaml infra
