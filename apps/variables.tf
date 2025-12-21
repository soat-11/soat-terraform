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

# Database configuration
variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "soat_challenge_db"
}

variable "db_user" {
  description = "The database admin user"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the database admin user"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "The port for the database"
  type        = number
  default     = 5432
}

variable "db_host" {
  description = "The host for the database"
  type        = string
}

variable "app_port" {
  description = "Port for the application"
  type        = number
  default     = 3010
}

# Payment configuration
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

# Container images
variable "payment_image" {
  description = "Container image for payment service"
  type        = string
  default     = ""
}

variable "cart_image" {
  description = "Container image for cart service"
  type        = string
  default     = ""
}

variable "admin_image" {
  description = "Container image for admin service"
  type        = string
  default     = ""
}

