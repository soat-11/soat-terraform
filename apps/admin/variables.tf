variable "app_name" {
  description = "Application name"
  type        = string
  default     = "admin"
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

