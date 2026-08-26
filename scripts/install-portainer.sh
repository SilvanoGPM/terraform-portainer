#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

APT_OPTS="-o DPkg::Lock::Timeout=600"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
STACK_FILE="$SCRIPT_DIR/infra-stack.yaml"
LOG_FILE="$SCRIPT_DIR/install-portainer.log"

# Espelha toda a saída no log sem escondê-la do provisioner
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Aguardando o cloud-init concluir ==="
if command -v cloud-init >/dev/null 2>&1; then
    cloud-init status --wait || true
fi

echo "=== Atualizando o sistema ==="
sudo apt-get $APT_OPTS update -y
sudo apt-get $APT_OPTS upgrade -y

echo "=== Instalando o Docker ==="
sudo apt-get $APT_OPTS install -y docker.io curl iproute2

echo "=== Habilitando e iniciando o Docker ==="
sudo systemctl enable --now docker

echo "=== Verificando a instalação do Docker ==="
if ! command -v docker >/dev/null 2>&1; then
    echo "ERRO: o Docker não foi instalado."
    exit 1
fi
sudo docker version

echo "=== Adicionando usuário ao grupo docker ==="
sudo usermod -aG docker ubuntu || true
sudo usermod -aG docker "${USER:-root}" || true

echo "=== Obtendo IP de anúncio do Swarm ==="

ADVERTISE_IP=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}') || true

if [ -z "$ADVERTISE_IP" ]; then
    echo "ERRO: não foi possível determinar o IP de anúncio."
    exit 1
fi

echo "IP de anúncio detectado: $ADVERTISE_IP"

echo "=== Inicializando Docker Swarm ==="

SWARM_STATE=$(sudo docker info --format '{{.Swarm.LocalNodeState}}')

if [ "$SWARM_STATE" != "active" ]; then
    sudo docker swarm init --advertise-addr "$ADVERTISE_IP"
else
    echo "Swarm já está inicializado."
fi

echo ""
echo "=== Status do Swarm ==="
sudo docker node ls

echo ""
echo "=== Criando redes Docker ==="
sudo docker network create -d overlay traefik-public || true
sudo docker network create -d overlay portainer-agent || true

echo ""
echo "=== Deploy do Portainer e Traefik ==="
if [ ! -f "$STACK_FILE" ]; then
    echo "ERRO: arquivo de stack não encontrado em $STACK_FILE"
    exit 1
fi

sudo docker stack deploy -c "$STACK_FILE" infra
