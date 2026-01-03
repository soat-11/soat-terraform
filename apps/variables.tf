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

variable "backend_bucket" {
  description = "The name of the backend bucket"
  type        = string
  default     = "arao-soat-terraform-challenge"
}
