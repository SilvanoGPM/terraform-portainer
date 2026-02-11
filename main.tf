provider "aws" {
  region = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
        Project = var.project_name
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token != null ? var.cloudflare_api_token : "fake-token-for-disable-cloudflare-automation-when-token-not-provided"
}