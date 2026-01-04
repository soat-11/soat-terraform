# =============================================================================
# MongoDB Module - Outputs
# =============================================================================

output "private_ip" {
  description = "IP privado da instância MongoDB"
  value       = module.database.private_ip
}

output "connection_endpoint" {
  description = "Endpoint de conexão MongoDB (host:port)"
  value       = module.database.connection_endpoint
}

output "instance_id" {
  description = "ID da instância EC2 do MongoDB"
  value       = module.database.instance_id
}

output "security_group_id" {
  description = "ID do Security Group do MongoDB"
  value       = module.database.security_group_id
}

output "connection_uri" {
  description = "URI de conexão completa do MongoDB"
  value       = "mongodb://${var.db_user}:${var.db_password}@${module.database.private_ip}:27017/${var.database_name != "" ? var.database_name : var.project_name}?authSource=admin"
  sensitive   = true
}

output "connection_uri_admin" {
  description = "URI de conexão para o database admin"
  value       = "mongodb://${var.db_user}:${var.db_password}@${module.database.private_ip}:27017/admin?authSource=admin"
  sensitive   = true
}

