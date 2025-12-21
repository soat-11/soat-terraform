terraform {
  backend "s3" {
    bucket  = "soat-terraform-challenge"
    key     = "kubernetes/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}

