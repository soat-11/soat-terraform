variable "is_local" {
  description = "Whether running in local environment (LocalStack - Cognito not supported)"
  type        = bool
  default     = false
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "soat"
}

