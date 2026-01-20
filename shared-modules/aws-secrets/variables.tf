variable "app_name" {
  description = "Name of the application (used for naming the secret)"
  type        = string
}

variable "secret_data" {
  description = "Map of secret key-value pairs to store"
  type        = map(string)
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 0 # Set to 0 for immediate deletion in dev/test, use 7-30 for production
}

variable "tags" {
  description = "Additional tags to apply to the secret"
  type        = map(string)
  default     = {}
}
