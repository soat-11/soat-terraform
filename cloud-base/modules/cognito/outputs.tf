output "user_pool_id" {
  value       = aws_cognito_user_pool.aws_cognito_create_pool.id
  description = "The ID of the created Cognito User Pool"
}

output "app_client_id" {
  value       = aws_cognito_user_pool_client.aws_cognito_create_app_client.id
  description = "The ID of the created Cognito User Pool App Client"
}

output "user_pool_arn" {
  value       = aws_cognito_user_pool.aws_cognito_create_pool.arn
  description = "The ARN of the created Cognito User Pool"
}

