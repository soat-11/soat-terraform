variable "deployment_name" {
  description = "The name of the deployment to scale"
  type        = string
}

variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "min_replicas" {
  description = "The minimum number of replicas"
  type        = number
  default     = 1
}
variable "max_replicas" {
  description = "The maximum number of replicas"
  type        = number
  default     = 3
}

variable "average_cpu_utilization" {
  description = "The target average CPU utilization percentage"
  type        = number
  default     = 80
}

variable "average_memory_utilization" {
  description = "The target average Memory utilization percentage"
  type        = number
  default     = 60
}
