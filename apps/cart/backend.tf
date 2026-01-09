terraform {
  backend "s3" {
    bucket = "arao-soat-terraform-challenge"
    key    = "apps/cart/backend.tfstate"
    region = "us-east-1"
  }
}
