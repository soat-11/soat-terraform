resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc_soat.id

  route {
    cidr_block = "10.1.0.0/16"
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet_soat.id
  route_table_id = aws_route_table.route_table.id
}
