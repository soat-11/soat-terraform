# Backend configuration for local testing
# Uses local state instead of S3

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

