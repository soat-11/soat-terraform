output "private_ip" {
  value = module.database.private_ip
}

output "connection_endpoint" {
  value = module.database.connection_endpoint
}

output "instance_id" {
  value = module.database.instance_id
}

output "security_group_id" {
  value = module.database.security_group_id
}

output "connection_uri" {
  value     = "mongodb://${var.db_user}:${var.db_password}@${module.database.private_ip}:27017/${var.database_name != "" ? var.database_name : var.project_name}?authSource=admin"
  sensitive = true
}

output "connection_uri_admin" {
  value     = "mongodb://${var.db_user}:${var.db_password}@${module.database.private_ip}:27017/admin?authSource=admin"
  sensitive = true
}

output "database_name" {
  value = var.database_name != "" ? var.database_name : var.project_name
}

output "db_user" {
  value     = var.db_user
  sensitive = true
}

output "db_password" {
  value     = var.db_password
  sensitive = true
}
