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

# -----------------------------------------------------------------------------
# AWS Credentials (compartilhadas por todos os serviços)
# -----------------------------------------------------------------------------
variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  default     = ""
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Mercado Pago (apenas para payment)
# -----------------------------------------------------------------------------
variable "mercado_pago_pos_id" {
  description = "Mercado Pago POS ID"
  type        = string
}

variable "sqs_create_payment_url" {
  description = "SQS Create Payment Queue URL"
  type        = string
}

variable "mercado_pago_api_url" {
  description = "Mercado Pago API URL"
  type        = string
  default     = "https://api.mercadopago.com/"
}

variable "mercado_pago_payment_access_token" {
  description = "Mercado Pago Payment Access Token"
  type        = string
  sensitive   = true
}

variable "mercado_pago_webhook_secret_key" {
  description = "Mercado Pago Webhook Secret Key"
  type        = string
  sensitive   = true
}

variable "backend_bucket" {
  description = "The name of the backend bucket"
  type        = string
  default     = "arao-soat-terraform-challenge"
}

