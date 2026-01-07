
output "private_ip" {
  description = "IP privado da instância MongoDB"
  value       = module.mongo_db.private_ip
}

output "mongo_db_uri" {
  value     = module.mongo_db.connection_uri
  sensitive = true
}

output "mongo_db_name" {
  value = module.mongo_db.database_name
}

output "mongo_db_user" {
  value     = module.mongo_db.db_user
  sensitive = true
}

output "mongo_db_password" {
  value     = module.mongo_db.db_password
  sensitive = true
}
