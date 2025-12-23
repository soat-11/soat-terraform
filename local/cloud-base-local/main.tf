# Cloud Base - Local Testing Version
# This version works with LocalStack FREE (Community Edition)
# Note: ECR, Cognito are NOT available in free version

# ----------------------
# S3 Bucket (orders)
# ----------------------
resource "aws_s3_bucket" "orders" {
  bucket = "${var.project}-orders"
  tags = {
    Name        = "${var.project}-orders"
    Environment = "Local"
  }
}

# ----------------------
# Lambda Functions
# ----------------------
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project}-lambda-bucket"
}

# Create IAM role for Lambda (mock)
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

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

resource "aws_lambda_function" "signup" {
  function_name = "${var.project}-signup"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 15

  filename = "${path.module}/lambda.zip"

  depends_on = [aws_s3_bucket.lambda_bucket]
}

resource "aws_lambda_function" "login" {
  function_name = "${var.project}-login"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 15

  filename = "${path.module}/lambda.zip"

  depends_on = [aws_s3_bucket.lambda_bucket]
}

# ----------------------
# SSM Parameters (mock Cognito values)
# ----------------------
resource "aws_ssm_parameter" "user_pool_id" {
  name  = "/cognito/user_pool_id"
  type  = "String"
  value = "local-user-pool-id-mock"
}

resource "aws_ssm_parameter" "app_client_id" {
  name  = "/cognito/app_client_id"
  type  = "String"
  value = "local-app-client-id-mock"
}

# ----------------------
# API Gateway
# ----------------------
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project}-api-gateway"
  description = "API Gateway for local testing"
}

resource "aws_api_gateway_resource" "signup" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "signup"
}

resource "aws_api_gateway_method" "signup_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.signup.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "signup" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.signup.id
  http_method             = aws_api_gateway_method.signup_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.signup.invoke_arn
}

resource "aws_api_gateway_resource" "login" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "login"
}

resource "aws_api_gateway_method" "login_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "login" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.login.id
  http_method             = aws_api_gateway_method.login_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.login.invoke_arn
}

resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.signup,
    aws_api_gateway_integration.login
  ]
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}
