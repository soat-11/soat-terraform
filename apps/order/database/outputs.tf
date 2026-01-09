output "private_ip" {
  description = "IP privado da instância PostgreSQL"
  value       = module.postgres_db.private_ip
}

output "postgres_connection_endpoint" {
  description = "Endpoint de conexão PostgreSQL (host:port)"
  value       = module.postgres_db.connection_endpoint
}

output "postgres_instance_id" {
  description = "ID da instância EC2 do PostgreSQL"
  value       = module.postgres_db.instance_id
}

output "postgres_db_uri" {
  description = "URI de conexão completa do PostgreSQL"
  value       = module.postgres_db.connection_uri
  sensitive   = true
}

output "postgres_db_name" {
  description = "Nome do database"
  value       = module.postgres_db.database_name
}

output "postgres_db_user" {
  description = "Usuário do PostgreSQL"
  value       = module.postgres_db.db_user
  sensitive   = true
}

output "postgres_db_password" {
  description = "Senha do PostgreSQL"
  value       = module.postgres_db.db_password
  sensitive   = true
}

output "postgres_db_port" {
  description = "Porta do PostgreSQL"
  value       = module.postgres_db.db_port
}

