output "db_user" {
  value = aws_db_instance.db_instance.username
}

output "db_password" {
  value     = aws_db_instance.db_instance.password
  sensitive = true
}

output "db_name" {
  value = aws_db_instance.db_instance.db_name
}

output "db_host" {
  value = aws_db_instance.db_instance.address
}

output "db_port" {
  value = aws_db_instance.db_instance.port

}

