resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
}

resource "aws_route_table_association" "route_table_association" {
  for_each = {
    for idx, subnet_id in var.subnet_ids :
    idx => subnet_id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.route_table.id
}

