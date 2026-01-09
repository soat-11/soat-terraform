terraform {
  backend "s3" {
    bucket = "arao-soat-terraform-challenge"
    key    = "apps/cart/database/terraform.tfstate"
    region = "us-east-1"
  }
}
