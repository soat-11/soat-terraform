# =============================================================================
# Payment Database - Outputs
# =============================================================================

output "mongo_private_ip" {
  description = "IP privado da instância MongoDB"
  value       = module.mongo_db.private_ip
}

output "mongo_connection_endpoint" {
  description = "Endpoint de conexão MongoDB (host:port)"
  value       = module.mongo_db.connection_endpoint
}

output "mongo_instance_id" {
  description = "ID da instância EC2 do MongoDB"
  value       = module.mongo_db.instance_id
}

output "mongo_connection_uri" {
  description = "URI de conexão completa do MongoDB"
  value       = module.mongo_db.connection_uri
  sensitive   = true
}
