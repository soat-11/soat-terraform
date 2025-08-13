resource "aws_subnet" "subnet_main" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc_soat.id
  cidr_block              = cidrsubnet(aws_vpc.vpc_soat.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = [var.region_a, var.region_b][count.index]

  tags = {
    Name = "subnet-main-${count.index}"
  }
}
