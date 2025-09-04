variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "service_name" {
  description = "The name of the Kubernetes service to expose"
  type        = string
}

variable "service_port" {
  description = "The port on which the service is exposed"
  type        = number
}
