terraform {
  backend "s3" {
    bucket = var.backend_bucket
    key    = "apps/terraform.tfstate"
    region = "us-east-1"

  }
}

