terraform {
  backend "s3" {
    bucket  = "soat-terraform-challenge"
    key     = "cloud-base/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}

