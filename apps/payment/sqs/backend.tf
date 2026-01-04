terraform {
  backend "s3" {
    bucket = "arao-soat-terraform-challenge"
    key    = "apps/payment/sqs/terraform.tfstate"
    region = "us-east-1"
  }
}

