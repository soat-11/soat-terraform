variable "app_name" {
  description = "Application name"
  type        = string
  default     = "payment"
}

variable "image" {
  description = "Container image"
  type        = string
}

variable "ingress_host" {
  description = "Ingress host"
  type        = string
}

variable "cpu_request" {
  description = "CPU request"
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Memory request"
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "250m"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}

# Scaling
variable "min_replicas" {
  description = "Minimum replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum replicas"
  type        = number
  default     = 2
}

//envs

variable "vars" {
  description = "Variables"
  type = object({
    AWS_REGION                                     = string,
    AWS_ENDPOINT                                   = string,
    AWS_ACCESS_KEY_ID                              = string,
    AWS_SECRET_ACCESS_KEY                          = string,
    AWS_SQS_CREATE_PAYMENT_QUEUE_URL               = string,
    AWS_SQS_PAYMENT_PAID_QUEUE_URL                 = string,
    AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL = string,
    AWS_SQS_CANCEL_PAYMENT_QUEUE_URL               = string,
    MERCADO_PAGO_POS_ID                            = string,
    MERCADO_PAGO_API_URL                           = string,
    MERCADO_PAGO_PAYMENT_ACCESS_TOKEN              = string,
    MERCADO_PAGO_WEBHOOK_SECRET_KEY                = string,
    NODE_ENV                                       = string,
    PORT                                           = string,
    MONGODB_URI                                    = string,
    DB_HOST                                        = string,
  })
  sensitive = true
}


