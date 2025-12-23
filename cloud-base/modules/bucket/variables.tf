variable "project" {
  description = "The name of the project"
  type        = string
  default     = "soat-challenge"
}

variable "is_local" {
  description = "Whether running in local environment (LocalStack)"
  type        = bool
  default     = false
}

