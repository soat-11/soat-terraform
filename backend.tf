terraform {


  backend "s3" {
    bucket  = "soat-terraform-challenge-eduardo" // trocar pelo seu bucket
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}