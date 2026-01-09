terraform {
  backend "s3" {
    bucket = "arao-soat-terraform-challenge"
    key    = "cloud-base/terraform.tfstate"
    region = "us-east-1"
  }
}

