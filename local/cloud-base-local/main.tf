# Cloud Base - Local Testing Version
# Uses the SAME modules as production with is_local=true
# This ensures local environment mirrors production exactly

# ----------------------
# S3 Bucket (orders)
# ----------------------
module "bucket" {
  source   = "../../cloud-base/modules/bucket"
  is_local = true
  project  = var.project

}

# ----------------------
# Cognito (mocked in LocalStack)
# ----------------------
module "cognito" {
  source = "../../cloud-base/modules/cognito"

  project  = var.project
  is_local = true
}

# ----------------------
# Lambda Functions
# ----------------------
module "lambda" {
  source = "../../cloud-base/modules/lambda"

  project         = var.project
  is_local        = true
  lambda_zip_path = "${path.module}/lambda.zip"
}

