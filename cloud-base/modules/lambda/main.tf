locals {
  lambda_zip  = var.lambda_zip_path != "" ? var.lambda_zip_path : "${path.module}/lambda.zip"
  runtime     = var.is_local ? "nodejs18.x" : "nodejs22.x"
  handler_prefix = var.is_local ? "index" : "functions/signup"
}

# IAM Role for Lambda (only for LocalStack)
resource "aws_iam_role" "lambda_role" {
  count = var.is_local ? 1 : 0
  name  = "${var.project}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project}-lambda-bucket"

  tags = {
    Name        = "${var.project}-lambda"
    Environment = var.is_local ? "Local" : "Production"
  }
}

resource "aws_lambda_function" "signup" {
  function_name = "${var.project}-signup"
  role          = var.is_local ? aws_iam_role.lambda_role[0].arn : var.role_arn
  handler       = var.is_local ? "index.handler" : "functions/signup.handler"
  runtime       = local.runtime
  timeout       = 15

  filename         = local.lambda_zip
  source_code_hash = var.is_local ? null : filebase64sha256(local.lambda_zip)

  depends_on = [aws_s3_bucket.lambda_bucket]
}

resource "aws_lambda_function" "login" {
  function_name = "${var.project}-login"
  role          = var.is_local ? aws_iam_role.lambda_role[0].arn : var.role_arn
  handler       = var.is_local ? "index.handler" : "functions/login.handler"
  runtime       = local.runtime
  timeout       = 15

  filename         = local.lambda_zip
  source_code_hash = var.is_local ? null : filebase64sha256(local.lambda_zip)

  depends_on = [aws_s3_bucket.lambda_bucket]
}

