variable "project" {
  description = "The name of the project"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role to be used by Lambda functions (ignored when is_local=true)"
  type        = string
  default     = ""
}

variable "is_local" {
  description = "Whether running in local environment (LocalStack)"
  type        = bool
  default     = false
}

variable "lambda_zip_path" {
  description = "Path to the lambda.zip file"
  type        = string
  default     = ""
}

variable "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  type        = string
}

variable "cognito_app_client_id" {
  description = "The ID of the Cognito App Client"
}
