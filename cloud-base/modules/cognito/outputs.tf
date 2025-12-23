output "user_pool_id" {
  value       = var.is_local ? "local-user-pool-id-mock" : aws_cognito_user_pool.aws_cognito_create_pool[0].id
  description = "The ID of the created Cognito User Pool"
}

output "app_client_id" {
  value       = var.is_local ? "local-app-client-id-mock" : aws_cognito_user_pool_client.aws_cognito_create_app_client[0].id
  description = "The ID of the created Cognito User Pool App Client"
}

output "user_pool_arn" {
  value       = var.is_local ? "arn:aws:cognito-idp:us-east-1:000000000000:userpool/local-mock" : aws_cognito_user_pool.aws_cognito_create_pool[0].arn
  description = "The ARN of the created Cognito User Pool"
}

