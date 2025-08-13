output "subnet_ids" {
  value = aws_vpc.vpc_soat.id
}

output "vpc_id" {
  value = aws_vpc.vpc_soat.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc_soat.cidr_block
}
