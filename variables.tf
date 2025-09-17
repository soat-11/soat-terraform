variable "project" {
  description = "The name of the project"
  type        = string
  default     = "soat-challenge"
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}


variable "db_password" {
  description = "The password for the database admin user"
  type        = string
  sensitive   = true
}

variable "payment_access_token" {
  description = "Access token for the payment API"
  type        = string
  sensitive   = true
}

variable "payment_api_url" {
  description = "URL for the payment API"
  type        = string
}

variable "payment_user_id" {
  description = "User ID for the payment API"
  type        = number
}

variable "payment_pos_id" {
  description = "POS ID for the payment API"
  type        = string
}

variable "webhook_secret_signature_key" {
  description = "Secret signature key for webhook"
  type        = string
  sensitive   = true
}


variable "app_port" {
  description = "Port for the application"
  type        = number
  default     = 3010
}

variable "payment_webhook_url" {
  description = "URL for the payment webhook"
  type        = string

}


variable "app_base_url" {
  description = "Base URL for the application"
  type        = string
}

variable "lambda_package" {
  description = "Path to the Lambda ZIP file (generated via build)"
  type        = string
}
