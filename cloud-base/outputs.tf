output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = module.subnets.subnet_ids
}

output "security_group_ids" {
  description = "List of security group IDs"
  value       = module.security_group.security_group_ids
}

output "repository_url" {
  description = "ECR repository URL"
  value       = module.container_registry.repository_url
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
  sensitive   = true
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = module.cognito.user_pool_arn
}

output "cognito_app_client_id" {
  description = "Cognito App Client ID"
  value       = module.cognito.app_client_id

  sensitive = true
}

output "signup_lambda_arn" {
  description = "ARN of the signup Lambda function"
  value       = module.lambda.signup_lambda_arn
}

output "login_lambda_arn" {
  description = "ARN of the login Lambda function"
  value       = module.lambda.login_lambda_arn
}

output "signup_function_name" {
  description = "Name of the signup Lambda function"
  value       = module.lambda.function_name_signup
}

output "login_function_name" {
  description = "Name of the login Lambda function"
  value       = module.lambda.function_name_login
}

