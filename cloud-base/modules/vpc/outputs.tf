output "vpc_id" {
  value = aws_vpc.vpc_soat.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc_soat.cidr_block
}

data "aws_security_group" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc_soat.id]
  }
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

output "security_group_ids" {
  value = [data.aws_security_group.default.id]
}

