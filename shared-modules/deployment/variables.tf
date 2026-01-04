variable "app_name" {
  description = "API name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "replicas" {
  description = "Number of replicas for the deployment"
  type        = number
  default     = 1
}

variable "image" {
  description = "Container image for the deployment"
  type        = string
  default     = "PLACEHOLDER_IMAGE_URI" 
}

variable "image_pull_policy" {
  description = "Image pull policy: Always, IfNotPresent, or Never"
  type        = string
  default     = "IfNotPresent"
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

# Optimized for lightweight applications
variable "cpu_request" {
  description = "CPU request for the container"
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Memory request for the container"
  type        = string
  default     = "768Mi"
}

variable "cpu_limit" {
  description = "CPU limit for the container"
  type        = string
  default     = "250m"
}

variable "memory_limit" {
  description = "Memory limit for the container"
  type        = string
  default     = "1280Mi"
}

