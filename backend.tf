terraform {

  backend "s3" {
    bucket  = "soat-challenge-state"
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-1"
    profile = "soat"
  }
}
