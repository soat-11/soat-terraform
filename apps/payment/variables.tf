variable "app_name" {
  description = "Application name"
  type        = string
  default     = "payment"
}

variable "image" {
  description = "Container image"
  type        = string
}

variable "ingress_host" {
  description = "Ingress host"
  type        = string
}

# Database
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 3010
}

variable "app_base_url" {
  description = "Application base URL"
  type        = string
  default     = "/"
}

# Payment specific
variable "payment_access_token" {
  description = "Payment access token"
  type        = string
  sensitive   = true
}

variable "payment_api_url" {
  description = "Payment API URL"
  type        = string
}

variable "payment_user_id" {
  description = "Payment user ID"
  type        = number
}

variable "payment_pos_id" {
  description = "Payment POS ID"
  type        = string
}

variable "webhook_secret_signature_key" {
  description = "Webhook secret signature key"
  type        = string
  sensitive   = true
}

variable "webhook_api_url" {
  description = "Webhook API URL"
  type        = string
  default     = "/"
}

# Resources - optimized for lightweight apps
variable "cpu_request" {
  description = "CPU request"
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Memory request"
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "250m"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}

# Scaling
variable "min_replicas" {
  description = "Minimum replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum replicas"
  type        = number
  default     = 2
}

