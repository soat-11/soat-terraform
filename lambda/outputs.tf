output "lambda_auth_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.auth.arn
}

output "lambda_auth_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.auth.function_name
}
