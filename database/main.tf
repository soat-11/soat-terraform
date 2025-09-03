
resource "aws_secretsmanager_secret" "db" {
  name = "db-secret"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.username
    password = var.password
  })
}

locals {
  db_credentials = jsondecode(aws_secretsmanager_secret_version.db.secret_string)
}

resource "aws_db_instance" "db_instance" {
  instance_class         = var.instance_class
  engine                 = var.engine
  engine_version         = var.engine_version
  username               = local.db_credentials.username
  password               = local.db_credentials.password
  db_name                = var.db_name
  allocated_storage      = 10
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name
}
