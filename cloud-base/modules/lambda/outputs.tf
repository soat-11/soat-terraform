output "signup_lambda_arn" {
  description = "ARN of the signup Lambda function"
  value       = aws_lambda_function.signup.invoke_arn
}

output "function_name_signup" {
  description = "Name of the signup Lambda function"
  value       = aws_lambda_function.signup.function_name
}

output "login_lambda_arn" {
  description = "ARN of the login Lambda function"
  value       = aws_lambda_function.login.invoke_arn
}

output "function_name_login" {
  description = "Name of the login Lambda function"
  value       = aws_lambda_function.login.function_name
}

