variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "secret_data" {
  description = "Map of secret key-value pairs"
  type        = map(string)
  sensitive   = true
}

