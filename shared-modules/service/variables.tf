variable "app_name" {
  description = "API name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "deployment_name" {
  description = "Deployment name"
  type        = string
}

variable "container_port" {
  description = "Container port for the service"
  type        = number
  default     = 3010
}

variable "service_port" {
  description = "Service port for the service"
  type        = number
  default     = 80
}

variable "service_type" {
  description = "Type of Kubernetes service"
  type        = string
  default     = "ClusterIP"
}

