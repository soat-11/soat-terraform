output "user_pool_id" {
  value = aws_cognito_user_pool.aws_cognito_create_pool.id
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.aws_cognito_create_app_client.id
}
