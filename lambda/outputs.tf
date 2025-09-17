output "lambda_auth_arn" {
  description = "ARN da função Lambda de autenticação"
  value       = aws_lambda_function.auth.arn
}

output "lambda_auth_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.auth.function_name
}
