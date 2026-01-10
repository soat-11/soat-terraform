variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "service_name" {
  description = "The name of the Kubernetes service to expose"
  type        = string
}

variable "service_port" {
  description = "The port on which the service is exposed"
  type        = number
}

variable "host" {
  description = "The host for the ingress rule (empty string = accept any host)"
  type        = string
  default     = ""
}

variable "path" {
  description = "The path for the ingress rule"
  type        = string
  default     = "/"
}

variable "path_type" {
  description = "The path type for the ingress rule"
  type        = string
  default     = "Prefix"
}

variable "rewrite_target" {
  description = "The rewrite target for nginx (use $1, $2 for regex capture groups)"
  type        = string
  default     = "/"
}

