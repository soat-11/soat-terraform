terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    apigateway = "http://localhost:4566"
    cognitoidp = "http://localhost:4566"
    ecr        = "http://localhost:4566"
    iam        = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    s3         = "http://s3.localhost.localstack.cloud:4566"
    ssm        = "http://localhost:4566"
    sts        = "http://localhost:4566"
  }
}
