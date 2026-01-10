provider "aws" {
  region = "us-east-1"
}

module "mongo_db" {
  source = "../../../shared-modules/mongodb"

  project_name     = "production"
  db_user          = var.db_user
  db_password      = var.db_password
  backend_bucket   = var.backend_bucket
  data_volume_size = 1
}

