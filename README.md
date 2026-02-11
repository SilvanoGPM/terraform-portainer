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

Este projeto provisiona automaticamente uma infraestrutura completa de **Docker Swarm** na **AWS** ou **Hetzner Cloud** utilizando **Terraform**. Basta escolher o provedor através da variável `cloud_provider` e, com poucos comandos, você terá um cluster pronto para utilizar com:

- **Portainer CE** - Interface gráfica para gerenciamento do cluster
- **Traefik v3.4** - Reverse proxy com SSL automático via Let's Encrypt
- **Integração com Cloudflare** - Registro DNS automático (opcional)

O número de **Managers** e **Workers** é totalmente configurável através de variáveis, permitindo escalar sua infraestrutura conforme a necessidade.

## Features

| Feature | Descrição |
|---------|-----------|
| **Multi-Cloud** | Suporte a AWS e Hetzner Cloud com a mesma base de código |
| **Cluster Escalável** | Configure quantos managers e workers desejar |
| **SSL Automático** | Certificados Let's Encrypt gerenciados pelo Traefik |
| **DNS Automático** | Integração opcional com Cloudflare para criação de registros |
| **Interface Gráfica** | Portainer CE para gerenciamento visual do Swarm |
| **Infraestrutura como Código** | 100% reproduzível e versionável |
| **Ubuntu 22.04 LTS** | Imagem utilizada em ambos os provedores |

## Arquitetura

O projeto suporta dois provedores de nuvem. A variável `cloud_provider` (`aws` ou `hetzner`) determina qual infraestrutura será provisionada.

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

Crie o arquivo `terraform.tfvars` na raiz do projeto. Escolha o exemplo correspondente ao seu provedor:

<details>
<summary><strong>Exemplo para AWS</strong></summary>

```hcl
# Provedor
cloud_provider = "aws"

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
cloudflare_api_token = "seu-token-cloudflare"
cloudflare_zone_id   = "sua-zone-id"
```

</details>

<details>
<summary><strong>Exemplo para Hetzner Cloud</strong></summary>

```hcl
# Provedor
cloud_provider = "hetzner"

# Hetzner Configuration
hetzner_api_token            = "seu-token-hetzner"
hetzner_ssh_private_key_path = "~/.ssh/id_ed25519"
hetzner_ssh_public_key_path  = "~/.ssh/id_ed25519.pub"
hetzner_server_type          = "cx22"
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
cloudflare_api_token = "seu-token-cloudflare"
cloudflare_zone_id   = "sua-zone-id"
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
# Inicializar providers
terraform init

# Visualizar plano de execução
terraform plan

# Aplicar infraestrutura
terraform apply
```

### 7. Acesse os painéis

Após a conclusão, você poderá acessar:

| Serviço | URL |
|---------|-----|
| **Portainer** | `https://portainer.seudominio.com` |
| **Traefik** | `https://traefik.seudominio.com` |

## Variáveis

### Obrigatórias

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `project_name` | `string` | Nome do projeto (usado para tags e nome da chave SSH) |
| `domain` | `string` | Domínio para a aplicação (ex: `exemplo.com`) |
| `lets_encrypt_email` | `string` | Email para registro do certificado SSL |
| `traefik_user` | `string` | Credenciais do Traefik no formato `user:hashed_password` |

### Obrigatórias (AWS)

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `aws_profile` | `string` | Perfil do AWS CLI para autenticação |
| `aws_ssh_private_key_path` | `string` | Caminho para a chave SSH privada |

### Obrigatórias (Hetzner)

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `hetzner_api_token` | `string` | Token da API da Hetzner Cloud |
| `hetzner_ssh_private_key_path` | `string` | Caminho para a chave SSH privada |
| `hetzner_ssh_public_key_path` | `string` | Caminho para a chave SSH pública |

### Opcionais

| Variável | Tipo | Default | Descrição |
|----------|------|---------|-----------|
| `cloud_provider` | `string` | `aws` | Provedor de nuvem (`aws` ou `hetzner`) |
| `environment` | `string` | `dev` | Ambiente de implantação (ex.: dev, staging, prod) |
| `aws_region` | `string` | `us-east-1` | Região AWS |
| `aws_instance_type` | `string` | `t2.micro` | Tipo de instância EC2 |
| `hetzner_server_type` | `string` | `cx22` | Tipo de servidor Hetzner (ex.: cx22, cpx21, cx32) |
| `hetzner_location` | `string` | `nbg1` | Datacenter Hetzner (nbg1, fsn1, hel1, ash) |
| `hetzner_image` | `string` | `ubuntu-22.04` | Imagem do SO para servidores Hetzner |
| `docker_swarm_manager_count` | `number` | `1` | Quantidade de nós Manager |
| `docker_swarm_worker_count` | `number` | `0` | Quantidade de nós Worker |
| `cloudflare_api_token` | `string` | `null` | Token da API do Cloudflare |
| `cloudflare_zone_id` | `string` | `""` | Zone ID do Cloudflare |

## Outputs

Após o `terraform apply`, os seguintes outputs estarão disponíveis:

| Output | Descrição |
|--------|-----------|
| `cloud_provider` | Provedor de nuvem utilizado |
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
├── main.tf              # Configuração dos providers
├── variables.tf         # Definição das variáveis
├── versions.tf          # Versões do Terraform e providers
├── validation.tf        # Validação de variáveis por provedor
├── outputs.tf           # Outputs do Terraform
├── locals.tf            # Variáveis locais
├── data.tf              # Data sources (AMI, etc.)
├── aws_ec2.tf           # Recursos EC2 (instâncias, provisioners)
├── aws_network.tf       # Configuração de rede (VPC, Subnets)
├── aws_sg.tf            # Security Groups AWS
├── hetzner_server.tf    # Servidores Hetzner Cloud (instâncias, provisioners)
├── hetzner_firewall.tf  # Firewall Hetzner Cloud
├── cloudflare.tf        # Recursos do Cloudflare
├── scripts/
│   └── install-portainer.sh    # Script de instalação do Portainer
├── stacks/
│   └── infra-stack.yaml.tpl    # Template do Docker Stack
└── terraform.tfvars     # Suas variáveis (não versionado)
```

## Destruindo a Infraestrutura

Para remover todos os recursos criados:

```bash
terraform destroy
```

> **Atenção:** Este comando irá destruir todas as instâncias EC2 e recursos associados. Certifique-se de ter backup dos dados importantes.
