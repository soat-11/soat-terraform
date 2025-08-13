data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnet_main" {
  count                   = 2
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet-main-${count.index}"
  }
}
