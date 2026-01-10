variable "project" {
  description = "The name of the project"
  type        = string
  default     = "soat-challenge"
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}


variable "payment_image" {
  description = "Container image for payment service"
  type        = string
  default     = ""
}

variable "cart_image" {
  description = "Container image for cart service"
  type        = string
  default     = ""
}

variable "admin_image" {
  description = "Container image for admin service"
  type        = string
  default     = ""
}

variable "production_image" {
  description = "Container image for production service"
  type        = string
  default     = ""
}

variable "order_image" {
  description = "Container image for order service"
  type        = string
  default     = ""
}

variable "production_vars" {
  description = "production variables"
  type = object({
    AWS_REGION            = string
    AWS_ACCESS_KEY_ID     = string
    AWS_SECRET_ACCESS_KEY = string
  })
  sensitive = true
}

variable "order_vars" {
  description = "order variables"
  type = object({
    AWS_REGION            = string
    AWS_ACCESS_KEY_ID     = string
    AWS_SECRET_ACCESS_KEY = string
  })
  sensitive = true
}

variable "payment_vars" {
  description = "payment variables (MONGODB_URI e DB_HOST são injetados automaticamente)"
  type = object({
    AWS_REGION                                     = string
    AWS_ENDPOINT                                   = optional(string, "")
    AWS_ACCESS_KEY_ID                              = optional(string, "")
    AWS_SECRET_ACCESS_KEY                          = optional(string, "")
    AWS_SQS_CREATE_PAYMENT_QUEUE_URL               = optional(string, "")
    AWS_SQS_PAYMENT_PAID_QUEUE_URL                 = optional(string, "")
    AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL = optional(string, "")
    AWS_SQS_CANCEL_PAYMENT_QUEUE_URL               = optional(string, "")
    MERCADO_PAGO_POS_ID                            = string
    MERCADO_PAGO_API_URL                           = string
    MERCADO_PAGO_PAYMENT_ACCESS_TOKEN              = string
    MERCADO_PAGO_WEBHOOK_SECRET_KEY                = string
    NODE_ENV                                       = string
    PORT                                           = string
    MONGODB_URI                                    = optional(string, "")
    DB_HOST                                        = optional(string, "")
  })
  sensitive = true
}

variable "backend_bucket" {
  description = "The name of the backend bucket"
  type        = string
  default     = "arao-soat-terraform-challenge"
}

