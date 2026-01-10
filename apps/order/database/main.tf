provider "aws" {
  region = "us-east-1"
}

module "postgres_db" {
  source = "../../../shared-modules/postgresql"

  project_name     = "order"
  db_user          = var.db_user
  db_password      = var.db_password
  backend_bucket   = var.backend_bucket
  database_name    = "orders_db"
  data_volume_size = 1
}

