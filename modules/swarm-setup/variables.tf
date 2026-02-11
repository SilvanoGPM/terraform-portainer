# ========================
# SSH e Conexão
# ========================

variable "ssh_user" {
  type        = string
  description = "Usuário SSH para conexão nos servidores"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Caminho para a chave privada SSH"
}

variable "home_dir" {
  type        = string
  description = "Diretório home do usuário SSH (ex: /home/ubuntu ou /root)"
}

variable "sudo_prefix" {
  type        = string
  description = "Prefixo sudo para comandos (ex: 'sudo ' para AWS, '' para Hetzner)"
  default     = ""
}

# ========================
# IPs dos Servidores
# ========================

variable "primary_public_ip" {
  type        = string
  description = "IP público do manager primário"
}

variable "swarm_join_ip" {
  type        = string
  description = "IP usado para join no swarm (private_ip na AWS, public_ip na Hetzner)"
}

variable "manager_public_ips" {
  type        = list(string)
  description = "Lista de IPs públicos dos managers adicionais"
  default     = []
}

variable "worker_public_ips" {
  type        = list(string)
  description = "Lista de IPs públicos dos workers"
  default     = []
}

# ========================
# Aplicação / Stack
# ========================

variable "domain" {
  type        = string
  description = "Nome de domínio para a aplicação"
}

variable "lets_encrypt_email" {
  type        = string
  description = "Email para registro do certificado SSL Let's Encrypt"
}

variable "traefik_user" {
  type        = string
  description = "Usuário e senha para o painel do Traefik (formato: user:hashed_password)"
  sensitive   = true
}

variable "environment" {
  type        = string
  description = "Ambiente de implantação (dev, staging, prod)"
  default     = "dev"
}

# ========================
# Caminhos
# ========================

variable "scripts_path" {
  type        = string
  description = "Caminho absoluto para o diretório de scripts"
}

variable "stacks_path" {
  type        = string
  description = "Caminho absoluto para o diretório de stacks"
}
