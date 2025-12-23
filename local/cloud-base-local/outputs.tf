# Outputs for local testing - mirrors production outputs

output "s3_orders_bucket" {
  value = module.bucket.bucket_name
}

output "signup_lambda_arn" {
  value = module.lambda.signup_lambda_arn
}

output "signup_function_name" {
  value = module.lambda.function_name_signup
}

output "login_lambda_arn" {
  value = module.lambda.login_lambda_arn
}

output "login_function_name" {
  value = module.lambda.function_name_login
}

output "cognito_user_pool_id" {
  value     = module.cognito.user_pool_id
  sensitive = true
}

output "cognito_app_client_id" {
  value     = module.cognito.app_client_id
  sensitive = true
}

output "cognito_user_pool_arn" {
  value = module.cognito.user_pool_arn
}

output "repository_url" {
  value       = "localhost:5000/${var.project}-repository"
  description = "Mock value - ECR not available in LocalStack Free, use local Docker registry"
}
