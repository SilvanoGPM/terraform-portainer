# cria VPC padrão se não existir
resource "aws_default_vpc" "default_vpc" {
  count = local.is_aws ? 1 : 0
}

# cria subnet padrão na zona de disponibilidade selecionada
resource "aws_default_subnet" "default_az1" {
  count             = local.is_aws ? 1 : 0
  availability_zone = data.aws_availability_zones.available_zones[0].names[0]
}
