variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_user" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "The database host"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "The database port"
  type        = number
  default     = 5432
}

variable "app_port" {
  description = "The name of the application"
  type        = string
}


variable "app_base_url" {
  description = "The Kubernetes namespace"
  type        = string
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
  type        = string
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

variable "webhook_api_url" {
  description = "URL for the webhook API"
  type        = string
}
