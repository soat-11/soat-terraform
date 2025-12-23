variable "db_name" {
  description = "Database name"
  type        = string
  default     = "soat_db"
}

variable "MERCADO_PAGO_WEBHOOK_SECRET_KEY" {
  description = "Mercado Pago webhook secret key"
  type        = string
  sensitive   = true
}

variable "MERCADO_PAGO_PAYMENT_ACCESS_TOKEN" {
  description = "Mercado Pago payment access token"
  type        = string
  sensitive   = true
}

variable "MERCADO_PAGO_API_URL" {
  description = "Mercado Pago API URL"
  type        = string
}

variable "MERCADO_PAGO_POS_ID" {
  description = "Mercado Pago POS ID"
  type        = string
}

variable "AWS_REGION" {
  description = "AWS Region"
  type        = string
}

variable "AWS_ENDPOINT" {
  description = "AWS Endpoint"
  type        = string
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key ID"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "AWS_SQS_CREATE_PAYMENT_QUEUE_URL" {
  description = "AWS SQS Create Payment Queue URL"
  type        = string
}

variable "AWS_SQS_PAYMENT_PAID_QUEUE_URL" {
  description = "AWS SQS Payment Paid Queue URL"
  type        = string
}

variable "AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL" {
  description = "AWS SQS Mercado Pago Process Payment Queue URL"
  type        = string
}

variable "AWS_SQS_CANCEL_PAYMENT_QUEUE_URL" {
  description = "AWS SQS Cancel Payment Queue URL"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "localpassword"
}

variable "db_host" {
  description = "Database host"
  type        = string
  default     = "host.docker.internal"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "NODE_ENV" {
  description = "Node Environment"
  type        = string
  default     = "development"
}

variable "PORT" {
  description = "Port"
  type        = number
  default     = 3010
}

variable "MONGODB_URI" {
  description = "MongoDB URI"
  type        = string
  default     = "mongodb://mongo:27017/payment"
}



# Use nginx:alpine as placeholder image for testing
variable "payment_image" {
  description = "Payment service image"
  type        = string
  default     = "soat-payment:latest"
}

variable "cart_image" {
  description = "Cart service image"
  type        = string
  default     = "nginx:alpine"
}

variable "admin_image" {
  description = "Admin service image"
  type        = string
  default     = "nginx:alpine"
}

