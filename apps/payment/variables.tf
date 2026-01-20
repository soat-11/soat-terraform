# -----------------------------------------------------------------------------
# App Config
# -----------------------------------------------------------------------------
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "payment"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 3010
}

variable "node_env" {
  description = "Node environment"
  type        = string
  default     = "production"
}

variable "image" {
  description = "Container image"
  type        = string
}

variable "image_pull_policy" {
  description = "Image pull policy"
  type        = string
  default     = "IfNotPresent"
}

variable "ingress_host" {
  description = "Ingress host"
  type        = string
}

# -----------------------------------------------------------------------------
# Resources
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# IRSA - OIDC Provider configuration
# -----------------------------------------------------------------------------
variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL (without https://)"
  type        = string
}

variable "producer_queue_arns" {
  description = "List of SQS queue ARNs that this service can send messages to"
  type        = list(string)
  default     = []
}

variable "consumer_queue_arns" {
  description = "List of SQS queue ARNs that this service can receive messages from"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# AWS Credentials
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

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
# SQS URLs
# -----------------------------------------------------------------------------
variable "sqs_create_payment_url" {
  description = "SQS Create Payment Queue URL"
  type        = string
}

variable "sqs_payment_paid_url" {
  description = "SQS Payment Paid Queue URL"
  type        = string
}

variable "sqs_mercado_pago_process_payment_url" {
  description = "SQS Mercado Pago Process Payment Queue URL"
  type        = string
}

variable "sqs_cancel_payment_url" {
  description = "SQS Cancel Payment Queue URL"
  type        = string
}

# -----------------------------------------------------------------------------
# Database
# -----------------------------------------------------------------------------
variable "mongodb_uri" {
  description = "MongoDB connection URI"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database host"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# External Services
# -----------------------------------------------------------------------------
variable "cart_api_url" {
  description = "Cart API URL"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Mercado Pago
# -----------------------------------------------------------------------------
variable "mercado_pago_pos_id" {
  description = "Mercado Pago POS ID"
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
