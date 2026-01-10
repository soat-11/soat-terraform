output "signup_lambda_arn" {
  description = "ARN of the signup Lambda function"
  value       = aws_lambda_function.signup_and_login.invoke_arn
}

output "function_name_signup" {
  description = "Name of the signup Lambda function"
  value       = aws_lambda_function.signup_and_login.function_name
}

output "login_lambda_arn" {
  description = "ARN of the login Lambda function"
  value       = aws_lambda_function.anonymous_login.invoke_arn
}

output "function_name_login" {
  description = "Name of the login Lambda function"
  value       = aws_lambda_function.anonymous_login.function_name
}

