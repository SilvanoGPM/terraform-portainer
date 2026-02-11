provider "aws" {
  region  = var.aws_region
  profile = local.is_aws ? var.aws_profile : null

  # Quando AWS não é o provider selecionado, usa credenciais dummy para evitar erros de autenticação
  access_key = local.is_aws ? null : "mock"
  secret_key = local.is_aws ? null : "mock"

  skip_credentials_validation = local.is_aws ? false : true
  skip_requesting_account_id  = local.is_aws ? false : true

  default_tags {
    tags = {
      Project = var.project_name
    }
  }
}

provider "hcloud" {
  token = var.hetzner_api_token != null ? var.hetzner_api_token : "fake-token-for-disable-hetzner-when-not-used-must-have-64-charss"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token != null ? var.cloudflare_api_token : "fake-token-for-disable-cloudflare-automation-when-token-not-provided"
}