terraform {
  required_version = "~> 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}
