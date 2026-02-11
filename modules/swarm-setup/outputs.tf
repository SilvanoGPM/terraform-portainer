output "primary_setup_id" {
  description = "ID do null_resource do setup primário (para dependências)"
  value       = null_resource.primary_setup.id
}
