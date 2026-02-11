resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}
