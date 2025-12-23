# Outputs for local testing

output "s3_orders_bucket" {
  value = aws_s3_bucket.orders.bucket
}

output "s3_lambda_bucket" {
  value = aws_s3_bucket.lambda_bucket.bucket
}

output "signup_lambda_arn" {
  value = aws_lambda_function.signup.arn
}

output "login_lambda_arn" {
  value = aws_lambda_function.login.arn
}

output "api_gateway_url" {
  value = aws_api_gateway_stage.prod.invoke_url
}

# Mock values for services not available in LocalStack Free
output "cognito_user_pool_id" {
  value       = aws_ssm_parameter.user_pool_id.value
  description = "Mock value - Cognito not available in LocalStack Free"

  sensitive = true
}

output "cognito_app_client_id" {
  value       = aws_ssm_parameter.app_client_id.value
  description = "Mock value - Cognito not available in LocalStack Free"

  sensitive = true
}

output "repository_url" {
  value       = "localhost:4566/soat-challenge-repository"
  description = "Mock value - ECR not available in LocalStack Free"
}
