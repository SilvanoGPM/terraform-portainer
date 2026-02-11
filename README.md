<h1 align="center">
  <br>
  Terraform + Docker Swarm + Portainer + Traefik
  <br>
</h1>

<h4 align="center">Infraestrutura como Código para deploy automatizado de um cluster Docker Swarm completo na AWS ou Hetzner Cloud</h4>

<p align="center">
  <img src="https://img.shields.io/badge/Terraform-1.6+-623CE4?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS">
  <img src="https://img.shields.io/badge/Hetzner-Cloud-D50C2D?style=for-the-badge&logo=hetzner&logoColor=white" alt="Hetzner Cloud">
  <img src="https://img.shields.io/badge/Docker-Swarm-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker Swarm">
  <img src="https://img.shields.io/badge/Traefik-v3.4-24A1C1?style=for-the-badge&logo=traefikproxy&logoColor=white" alt="Traefik">
  <img src="https://img.shields.io/badge/Portainer-CE-13BEF9?style=for-the-badge&logo=portainer&logoColor=white" alt="Portainer">
</p>

<p align="center">
  <a href="#sobre">Sobre</a> •
  <a href="#features">Features</a> •
  <a href="#arquitetura">Arquitetura</a> •
  <a href="#pré-requisitos">Pré-requisitos</a> •
  <a href="#instalação">Instalação</a> •
  <a href="#variáveis">Variáveis</a> •
  <a href="#outputs">Outputs</a> •
  <a href="#estrutura-do-projeto">Estrutura</a>
</p>

---

## Sobre

Este projeto provisiona automaticamente uma infraestrutura completa de **Docker Swarm** na **AWS** ou **Hetzner Cloud** utilizando **Terraform**. Cada provedor possui seu próprio root module independente em `live/`. Basta entrar no diretório do provedor desejado e executar `terraform apply`:

- **Portainer CE** - Interface gráfica para gerenciamento do cluster
- **Traefik v3.4** - Reverse proxy com SSL automático via Let's Encrypt
- **Integração com Cloudflare** - Registro DNS automático (opcional)

O número de **Managers** e **Workers** é totalmente configurável através de variáveis, permitindo escalar sua infraestrutura conforme a necessidade.

## Features

| Feature | Descrição |
|---------|-----------|
| **Multi-Cloud** | Suporte a AWS e Hetzner Cloud com módulos compartilhados |
| **Root Modules Independentes** | Cada provedor tem seu próprio diretório, sem condicionais ou mocks |
| **Cluster Escalável** | Configure quantos managers e workers desejar |
| **SSL Automático** | Certificados Let's Encrypt gerenciados pelo Traefik |
| **DNS Automático** | Integração opcional com Cloudflare para criação de registros |
| **Interface Gráfica** | Portainer CE para gerenciamento visual do Swarm |
| **Infraestrutura como Código** | 100% reproduzível e versionável |
| **Ubuntu 22.04 LTS** | Imagem utilizada em ambos os provedores |

## Arquitetura

O projeto possui root modules independentes por provedor em `live/`. Módulos compartilhados em `modules/` cuidam do provisionamento Docker Swarm e DNS.

### AWS

```
                                    ┌─────────────────────────────────────────┐
                                    │              CLOUDFLARE                 │
                                    │         (DNS Automático - Opcional)     │
                                    └─────────────────┬───────────────────────┘
                                                      │
                                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                         AWS VPC                                         │
│  ┌────────────────────────────────────────────────────────────────────────────────────┐ │
│  │                              Security Group (Docker)                               │ │
│  │                                                                                    │ │
│  │   ┌─────────────────────────────────────────────────────────────────────────────┐  │ │
│  │   │                          DOCKER SWARM CLUSTER                               │  │ │
│  │   │                                                                             │  │ │
│  │   │  ┌──────────────────────┐    ┌──────────────────┐    ┌──────────────────┐   │  │ │
│  │   │  │   MANAGER PRIMARY    │    │    MANAGER N     │    │    MANAGER N     │   │  │ │
│  │   │  │  ┌────────────────┐  │    │                  │    │                  │   │  │ │
│  │   │  │  │   Portainer    │  │    │   (Opcional)     │    │   (Opcional)     │   │  │ │
│  │   │  │  ├────────────────┤  │    │                  │    │                  │   │  │ │
│  │   │  │  │    Traefik     │  │    │                  │    │                  │   │  │ │
│  │   │  │  └────────────────┘  │    │                  │    │                  │   │  │ │
│  │   │  │   Ubuntu 22.04 LTS   │    │ Ubuntu 22.04 LTS │    │ Ubuntu 22.04 LTS │   │  │ │
│  │   │  └──────────────────────┘    └──────────────────┘    └──────────────────┘   │  │ │
│  │   │                                                                             │  │ │
│  │   │  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐       │  │ │
│  │   │  │    WORKER 1      │    │    WORKER 2      │    │    WORKER N      │       │  │ │
│  │   │  │                  │    │                  │    │                  │       │  │ │
│  │   │  │   (Opcional)     │    │   (Opcional)     │    │   (Opcional)     │       │  │ │
│  │   │  │ Ubuntu 22.04 LTS │    │ Ubuntu 22.04 LTS │    │ Ubuntu 22.04 LTS │       │  │ │
│  │   │  └──────────────────┘    └──────────────────┘    └──────────────────┘       │  │ │
│  │   └─────────────────────────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### Hetzner Cloud

```
                                    ┌─────────────────────────────────────────┐
                                    │              CLOUDFLARE                 │
                                    │         (DNS Automático - Opcional)     │
                                    └─────────────────┬───────────────────────┘
                                                      │
                                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                     HETZNER CLOUD                                       │
│  ┌────────────────────────────────────────────────────────────────────────────────────┐ │
│  │                             Firewall (Docker Swarm)                                │ │
│  │                                                                                    │ │
│  │   ┌─────────────────────────────────────────────────────────────────────────────┐  │ │
│  │   │                          DOCKER SWARM CLUSTER                               │  │ │
│  │   │                                                                             │  │ │
│  │   │  ┌──────────────────────┐    ┌──────────────────┐    ┌──────────────────┐   │  │ │
│  │   │  │   MANAGER PRIMARY    │    │    MANAGER N     │    │    MANAGER N     │   │  │ │
│  │   │  │  ┌────────────────┐  │    │                  │    │                  │   │  │ │
│  │   │  │  │   Portainer    │  │    │   (Opcional)     │    │   (Opcional)     │   │  │ │
│  │   │  │  ├────────────────┤  │    │                  │    │                  │   │  │ │
│  │   │  │  │    Traefik     │  │    │                  │    │                  │   │  │ │
│  │   │  │  └────────────────┘  │    │                  │    │                  │   │  │ │
│  │   │  │   Ubuntu 22.04 LTS   │    │ Ubuntu 22.04 LTS │    │ Ubuntu 22.04 LTS │   │  │ │
│  │   │  └──────────────────────┘    └──────────────────┘    └──────────────────┘   │  │ │
│  │   │                                                                             │  │ │
│  │   │  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐       │  │ │
│  │   │  │    WORKER 1      │    │    WORKER 2      │    │    WORKER N      │       │  │ │
│  │   │  │                  │    │                  │    │                  │       │  │ │
│  │   │  │   (Opcional)     │    │   (Opcional)     │    │   (Opcional)     │       │  │ │
│  │   │  │ Ubuntu 22.04 LTS │    │ Ubuntu 22.04 LTS │    │ Ubuntu 22.04 LTS │       │  │ │
│  │   │  └──────────────────┘    └──────────────────┘    └──────────────────┘       │  │ │
│  │   └─────────────────────────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

## Pré-requisitos

Antes de começar, certifique-se de ter:

- [Terraform](https://www.terraform.io/downloads) >= 1.6
- Domínio próprio (ex: `meudominio.com`) com acesso para configurar DNS
- Docker instalado localmente (para gerar a senha do Traefik)

**Para deploy na AWS:**
- [AWS CLI](https://aws.amazon.com/cli/) configurado com um perfil válido
- Chave SSH criada no console AWS (formato: `<PROJECT_NAME>-key`)

**Para deploy na Hetzner Cloud:**
- Conta na [Hetzner Cloud](https://www.hetzner.com/cloud) com um API Token gerado
- Par de chaves SSH (pública e privada) gerado localmente

## Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/SilvanoGPM/terraform-portainer.git
cd terraform-portainer
```

### 2. Configure a chave SSH

**AWS:** Acesse o console AWS e crie um Key Pair com o nome no formato `<PROJECT_NAME>-key`.

> **Exemplo:** Se seu `project_name` for `meu-projeto`, a chave deve se chamar `meu-projeto-key`

**Hetzner:** Gere um par de chaves SSH localmente (caso ainda não tenha):

```bash
ssh-keygen -t ed25519 -C "seu@email.com"
```

> A chave pública será registrada automaticamente na Hetzner Cloud pelo Terraform.

### 3. Gere a senha do Traefik

Execute o comando abaixo para gerar o hash da senha:

```bash
docker run --rm httpd:2.4-alpine htpasswd -nbB admin SUA_SENHA_AQUI
```

**Saída esperada:**
```
admin:$2y$05$w8K1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> Copie a saída completa para usar na variável `traefik_user`

### 4. Configure as variáveis

Entre no diretório do provedor desejado e crie o arquivo `terraform.tfvars`:

<details>
<summary><strong>Para AWS</strong></summary>

```bash
cd live/aws
```

Crie o arquivo `terraform.tfvars`:

```hcl
# AWS Configuration
aws_profile              = "default"
aws_region               = "us-east-1"
aws_instance_type        = "t2.micro"
aws_ssh_private_key_path = "~/.ssh/meu-projeto-key.pem"

# Project
project_name = "meu-projeto"

# Domain & SSL
domain             = "meudominio.com"
lets_encrypt_email = "seu@email.com"

# Traefik Auth (saída do comando htpasswd)
traefik_user = "admin:$2y$05$..."

# Docker Swarm
docker_swarm_manager_count = 1
docker_swarm_worker_count  = 2

# Cloudflare (opcional)
# cloudflare_api_token = "seu-token-cloudflare"
# cloudflare_zone_id   = "sua-zone-id"
```

</details>

<details>
<summary><strong>Para Hetzner Cloud</strong></summary>

```bash
cd live/hetzner
```

Crie o arquivo `terraform.tfvars`:

```hcl
# Hetzner Configuration
hetzner_api_token            = "seu-token-hetzner"
hetzner_ssh_private_key_path = "~/.ssh/id_ed25519"
hetzner_ssh_public_key_path  = "~/.ssh/id_ed25519.pub"
hetzner_server_type          = "cax11"
hetzner_location             = "nbg1"

# Project
project_name = "meu-projeto"

# Domain & SSL
domain             = "meudominio.com"
lets_encrypt_email = "seu@email.com"

# Traefik Auth (saída do comando htpasswd)
traefik_user = "admin:$2y$05$..."

# Docker Swarm
docker_swarm_manager_count = 1
docker_swarm_worker_count  = 2

# Cloudflare (opcional)
# cloudflare_api_token = "seu-token-cloudflare"
# cloudflare_zone_id   = "sua-zone-id"
```

</details>

### 5. Configure o DNS (se não usar Cloudflare)

Se você não quiser usar a automação do Cloudflare, configure manualmente:

| Campo | Valor |
|-------|-------|
| **Tipo** | A |
| **Nome** | * |
| **Conteúdo** | IP público do Manager Primary |
| **Proxy** | Desativado (DNS only) |
| **TTL** | Auto |

### 6. Execute o Terraform

```bash
# Dentro do diretório do provedor (live/aws ou live/hetzner)
terraform init
terraform plan
terraform apply
```

### 7. Acesse os painéis

Após a conclusão, você poderá acessar:

| Serviço | URL |
|---------|-----|
| **Portainer** | `https://portainer.seudominio.com` |
| **Traefik** | `https://traefik.seudominio.com` |

## Variáveis

### AWS (`live/aws/`)

| Variável | Tipo | Default | Descrição |
|----------|------|---------|-----------|
| `aws_profile` | `string` | - | Perfil do AWS CLI para autenticação |
| `aws_ssh_private_key_path` | `string` | - | Caminho para a chave SSH privada |
| `aws_region` | `string` | `us-east-1` | Região AWS |
| `aws_instance_type` | `string` | `t2.micro` | Tipo de instância EC2 |
| `aws_default_user` | `string` | `ubuntu` | Usuário padrão das instâncias EC2 |

### Hetzner (`live/hetzner/`)

| Variável | Tipo | Default | Descrição |
|----------|------|---------|-----------|
| `hetzner_api_token` | `string` | - | Token da API da Hetzner Cloud |
| `hetzner_ssh_private_key_path` | `string` | - | Caminho para a chave SSH privada |
| `hetzner_ssh_public_key_path` | `string` | - | Caminho para a chave SSH pública |
| `hetzner_server_type` | `string` | `cax11` | Tipo de servidor Hetzner |
| `hetzner_location` | `string` | `nbg1` | Datacenter Hetzner |
| `hetzner_image` | `string` | `ubuntu-22.04` | Imagem do SO |
| `hetzner_default_user` | `string` | `root` | Usuário padrão dos servidores |

### Comuns (ambos os provedores)

| Variável | Tipo | Default | Descrição |
|----------|------|---------|-----------|
| `project_name` | `string` | - | Nome do projeto (tags e nome da chave SSH) |
| `domain` | `string` | - | Domínio para a aplicação |
| `lets_encrypt_email` | `string` | - | Email para registro SSL |
| `traefik_user` | `string` | - | Credenciais do Traefik (`user:hashed_password`) |
| `environment` | `string` | `dev` | Ambiente (dev, staging, prod) |
| `docker_swarm_manager_count` | `number` | `1` | Quantidade de nós Manager |
| `docker_swarm_worker_count` | `number` | `0` | Quantidade de nós Worker |
| `cloudflare_api_token` | `string` | `null` | Token da API do Cloudflare (opcional) |
| `cloudflare_zone_id` | `string` | `""` | Zone ID do Cloudflare (opcional) |

## Outputs

Após o `terraform apply`, os seguintes outputs estarão disponíveis:

| Output | Descrição |
|--------|-----------|
| `manager_primary_public_ip` | IP público do Manager Primary |
| `manager_primary_ssh_connect` | Comando SSH pronto para conexão |
| `urls` | URLs do Traefik e Portainer |

**Exemplo de uso:**

```bash
# Ver todos os outputs
terraform output

# Conectar via SSH
$(terraform output -raw manager_primary_ssh_connect)
```

## Estrutura do Projeto

```
terraform-portainer/
├── modules/
│   ├── swarm-setup/                  # Módulo compartilhado: provisionamento Docker Swarm
│   │   ├── main.tf                   # null_resources: setup primário, join managers/workers
│   │   ├── variables.tf              # IPs, SSH config, stack vars, paths
│   │   └── outputs.tf
│   └── cloudflare-dns/               # Módulo compartilhado: DNS wildcard
│       ├── main.tf                   # cloudflare_record wildcard
│       ├── variables.tf
│       └── versions.tf
├── live/
│   ├── aws/                          # Root module AWS (terraform apply aqui)
│   │   ├── main.tf                   # Provider AWS + Cloudflare + module calls
│   │   ├── variables.tf              # Só variáveis AWS + projeto + cloudflare
│   │   ├── versions.tf               # Só providers aws + null + cloudflare
│   │   ├── outputs.tf
│   │   ├── data.tf                   # AMI + AZ
│   │   ├── network.tf                # Default VPC + subnet
│   │   ├── security_group.tf         # Security Group
│   │   └── instances.tf              # EC2 instances
│   └── hetzner/                      # Root module Hetzner (terraform apply aqui)
│       ├── main.tf                   # Provider hcloud + Cloudflare + module calls
│       ├── variables.tf              # Só variáveis Hetzner + projeto + cloudflare
│       ├── versions.tf               # Só providers hcloud + null + cloudflare
│       ├── outputs.tf
│       ├── ssh_key.tf                # hcloud_ssh_key
│       ├── firewall.tf               # Firewall
│       └── servers.tf                # Hetzner servers
├── scripts/
│   └── install-portainer.sh          # Script de instalação (cloud-agnostic)
├── stacks/
│   └── infra-stack.yaml.tpl          # Template do Docker Stack
└── terraform.tfvars                  # Suas variáveis (não versionado)
```

## Destruindo a Infraestrutura

Para remover todos os recursos criados:

```bash
# Dentro do diretório do provedor (live/aws ou live/hetzner)
terraform destroy
```

> **Atenção:** Este comando irá destruir todas as instâncias e recursos associados. Certifique-se de ter backup dos dados importantes.

## Certificado SSL

> O Let's Encrypt tem um limite de certificados por domínio. Recomendo utilizar o projeto com a variável `environment` diferente de `prod` para evitar atingir esse limite durante testes, o navegador pode exibir erros de certificado, porém fora de produção esses erros podem ser ignorados. Já em produção, utilize um valor como `prod` para garantir que os certificados sejam gerados corretamente.
