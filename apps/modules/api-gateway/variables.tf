variable "project" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "signup_lambda_arn" {
  description = "ARN of the signup lambda function"
  type        = string
}

variable "login_lambda_arn" {
  description = "ARN of the login lambda function"
  type        = string
}

variable "signup_function_name" {
  description = "Name of the signup lambda function"
  type        = string
}

variable "login_function_name" {
  description = "Name of the login lambda function"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  type        = string
}

variable "eks_nlb_hostname" {
  description = "Hostname of the EKS NLB or K8s Ingress (for local use host.docker.internal)"
  type        = string
}

variable "is_local" {
  description = "Whether running in local environment (LocalStack)"
  type        = bool
  default     = false
}

