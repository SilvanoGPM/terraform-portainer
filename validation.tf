resource "null_resource" "validate_provider_vars" {
  lifecycle {
    precondition {
      condition     = var.cloud_provider != "aws" || (var.aws_profile != null && var.aws_ssh_private_key_path != null)
      error_message = "Quando cloud_provider é 'aws', as variáveis 'aws_profile' e 'aws_ssh_private_key_path' são obrigatórias."
    }

    precondition {
      condition     = var.cloud_provider != "hetzner" || (var.hetzner_api_token != null && var.hetzner_ssh_private_key_path != null && var.hetzner_ssh_public_key_path != null)
      error_message = "Quando cloud_provider é 'hetzner', as variáveis 'hetzner_api_token', 'hetzner_ssh_private_key_path' e 'hetzner_ssh_public_key_path' são obrigatórias."
    }
  }
}
