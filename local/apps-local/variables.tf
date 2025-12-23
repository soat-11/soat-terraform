
variable "payment_image" {
  description = "Payment service image"
  type        = string
  default     = "soat-payment:latest"
}

variable "cart_image" {
  description = "Cart service image"
  type        = string
  default     = "soat-cart:latest"
}

variable "admin_image" {
  description = "Admin service image"
  type        = string
  default     = "soat-admin:latest"
}

variable "payment_vars" {
  description = "payment variables"
  type = object({
    AWS_REGION                                     = string
    AWS_ENDPOINT                                   = string
    AWS_ACCESS_KEY_ID                              = string
    AWS_SECRET_ACCESS_KEY                          = string
    AWS_SQS_CREATE_PAYMENT_QUEUE_URL               = string
    AWS_SQS_PAYMENT_PAID_QUEUE_URL                 = string
    AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL = string
    AWS_SQS_CANCEL_PAYMENT_QUEUE_URL               = string
    MERCADO_PAGO_POS_ID                            = string
    MERCADO_PAGO_API_URL                           = string
    MERCADO_PAGO_PAYMENT_ACCESS_TOKEN              = string
    MERCADO_PAGO_WEBHOOK_SECRET_KEY                = string
    NODE_ENV                                       = string
    PORT                                           = string
    MONGODB_URI                                    = string
    DB_HOST                                        = string
  })
  sensitive = true

}
