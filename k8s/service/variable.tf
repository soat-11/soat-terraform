variable "app_name" {
  description = "API name"
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
  default     = 5000
}
