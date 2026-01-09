output "subnet_ids" {
  description = "List of subnet IDs (application subnets)"
  value       = aws_subnet.subnet_main[*].id
}

output "database_subnet_id" {
  description = "ID da subnet dedicada para bancos de dados"
  value       = aws_subnet.database.id
}

output "database_subnet_cidr" {
  description = "CIDR block da subnet de database"
  value       = aws_subnet.database.cidr_block
}

