variable "cloud_provider" {
  type        = string
  description = "Provedor de nuvem para deploy (aws ou hetzner)"
  default     = "aws"
  validation {
    condition     = contains(["aws", "hetzner"], var.cloud_provider)
    error_message = "O provedor deve ser 'aws' ou 'hetzner'."
  }
}

# ========================
# Variáveis AWS
# ========================

variable "aws_region" {
  type        = string
  description = "Região AWS onde os recursos serão provisionados"
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "Perfil AWS CLI a ser usado para autenticação (obrigatório quando cloud_provider = aws)"
  default     = null
}

variable "aws_ssh_private_key_path" {
  type        = string
  description = "Caminho para a chave privada SSH para acesso à instância EC2 (obrigatório quando cloud_provider = aws)"
  default     = null
}

variable "aws_instance_type" {
  type        = string
  description = "Tipo de instância EC2 para os nós do Docker Swarm"
  default     = "t2.micro"
}

variable "aws_default_user" {
  type        = string
  description = "Usuário padrão para acesso às instâncias EC2"
  default     = "ubuntu"
}

# ========================
# Variáveis Hetzner
# ========================

variable "hetzner_api_token" {
  type        = string
  description = "Token da API da Hetzner Cloud (obrigatório quando cloud_provider = hetzner)"
  default     = null
  sensitive   = true
}

variable "hetzner_ssh_private_key_path" {
  type        = string
  description = "Caminho para a chave privada SSH para acesso aos servidores Hetzner (obrigatório quando cloud_provider = hetzner)"
  default     = null
}

variable "hetzner_ssh_public_key_path" {
  type        = string
  description = "Caminho para a chave pública SSH para registrar na Hetzner Cloud (obrigatório quando cloud_provider = hetzner)"
  default     = null
}

variable "hetzner_server_type" {
  type        = string
  description = "Tipo de servidor Hetzner Cloud (ex.: cx22, cpx21, cx32)"
  default     = "cx22"
}

variable "hetzner_location" {
  type        = string
  description = "Localização do datacenter Hetzner (nbg1=Nuremberg, fsn1=Falkenstein, hel1=Helsinki, ash=Ashburn)"
  default     = "nbg1"
}

variable "hetzner_image" {
  type        = string
  description = "Imagem do sistema operacional para os servidores Hetzner"
  default     = "ubuntu-22.04"
}

variable "hetzner_default_user" {
  type        = string
  description = "Usuário padrão para acesso aos servidores Hetzner"
  default     = "root"
}

# ========================
# Variáveis do Projeto
# ========================

variable "environment" {
  type        = string
  description = "Ambiente de implantação (ex.: dev, staging, prod)"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O ambiente deve ser 'dev', 'staging' ou 'prod'."
  }
}

variable "project_name" {
  type        = string
  description = "Nome do projeto para a marcação dos recursos"
}

variable "domain" {
  type        = string
  description = "Nome de domínio para a aplicação (ex.: exemplo.com)"
}

variable "lets_encrypt_email" {
  type        = string
  description = "Endereço de email para registro do certificado SSL Let's Encrypt"
}

variable "traefik_user" {
  type        = string
  description = "Usuário e senha para acesso ao painel do Traefik (formato: user:hashed_password)"
  sensitive   = true
}

# ========================
# Variáveis Cloudflare
# ========================

variable "cloudflare_api_token" {
  type        = string
  description = "Token da API do Cloudflare com permissões para gerenciar registros DNS"
  default     = null
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "ID da zona do Cloudflare para gerenciar registros DNS"
  default     = ""
  sensitive   = true
}

# ========================
# Variáveis Docker Swarm
# ========================

variable "docker_swarm_manager_count" {
  type        = number
  default     = 1
  description = "Número de nós Manager no cluster Docker Swarm"
}

variable "docker_swarm_worker_count" {
  type        = number
  default     = 0
  description = "Número de nós Worker no cluster Docker Swarm"
}
