terraform {
  backend "s3" {
    bucket = "arao-soat-terraform-challenge"
    key    = "kubernetes/terraform.tfstate"
    region = "us-east-1"

  }
}

