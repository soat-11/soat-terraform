variable "app_name" {
  description = "API name"
  type        = string
}

variable "replicas" {
  description = "Number of replicas for the deployment"
  type        = number
  default     = 1

}

variable "image" {
  description = "Container image for the deployment"
  type        = string
}

variable "container_port" {
  description = "Container port for the deployment"
  type        = number
  default     = 3010
}

variable "secret_name" {
  description = "Kubernetes secret name for environment variables"
  type        = string
  sensitive   = true
}

variable "cpu_request" {
  description = "CPU request for the container"
  type        = string
  default     = "250m"
}

variable "memory_request" {
  description = "Memory request for the container"
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "CPU limit for the container"
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Memory limit for the container"
  type        = string
  default     = "512Mi"
}

