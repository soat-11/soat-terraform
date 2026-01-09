
output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.database.id
}

output "private_ip" {
  description = "IP privado da instância (usar para conexão dentro da VPC)"
  value       = aws_instance.database.private_ip
}

output "public_ip" {
  description = "IP público da instância (null se em subnet privada)"
  value       = aws_instance.database.public_ip
}

output "private_dns" {
  description = "DNS privado da instância"
  value       = aws_instance.database.private_dns
}

output "security_group_id" {
  description = "ID do Security Group criado"
  value       = aws_security_group.database.id
}

output "data_volume_id" {
  description = "ID do volume EBS de dados"
  value       = aws_ebs_volume.data.id
}

output "data_volume_arn" {
  description = "ARN do volume EBS de dados (útil para políticas de backup)"
  value       = aws_ebs_volume.data.arn
}

output "availability_zone" {
  description = "Availability Zone onde os recursos foram criados"
  value       = data.aws_subnet.selected.availability_zone
}

output "connection_endpoint" {
  description = "Endpoint de conexão no formato host:port"
  value       = "${aws_instance.database.private_ip}:${var.db_port}"
}

