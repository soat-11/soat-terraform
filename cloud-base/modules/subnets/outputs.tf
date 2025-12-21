output "subnet_ids" {
  description = "List of subnet IDs"
  value       = aws_subnet.subnet_main[*].id
}

