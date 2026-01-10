output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "subnet_ids" {
  value = module.subnets.subnet_ids
}

output "database_subnet_id" {
  value = module.subnets.database_subnet_id
}

output "security_group_ids" {
  value = module.security_group.security_group_ids
}

output "repository_url" {
  value = module.container_registry.repository_url
}

output "payment_ecr_url" {
  value = module.payment_ecr.repository_url
}

output "cart_ecr_url" {
  value = module.cart_ecr.repository_url
}

output "production_ecr_url" {
  value = module.production_ecr.repository_url
}

output "order_ecr_url" {
  value = module.order_ecr.repository_url
}

output "cognito_user_pool_id" {
  value     = module.cognito.user_pool_id
  sensitive = true
}

output "cognito_user_pool_arn" {
  value = module.cognito.user_pool_arn
}

output "cognito_app_client_id" {
  value     = module.cognito.app_client_id
  sensitive = true
}

output "signup_lambda_arn" {
  value = module.lambda.signup_lambda_arn
}

output "login_lambda_arn" {
  value = module.lambda.login_lambda_arn
}

output "signup_function_name" {
  value = module.lambda.function_name_signup
}

output "login_function_name" {
  value = module.lambda.function_name_login
}
