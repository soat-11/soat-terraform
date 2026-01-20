variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID (opcional - IRSA é preferido)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key (opcional - IRSA é preferido)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "mongo_uri" {
  description = "The MongoDB URI"
  type        = string
  sensitive   = true
}

variable "app_port" {
  description = "The port for the application"
  type        = number
  default     = 3010
}

variable "min_replicas" {
  description = "The minimum number of replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "The maximum number of replicas"
  type        = number
  default     = 10
}

variable "ingress_host" {
  description = "The ingress host"
  type        = string
}

variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "production"
}

variable "cpu_request" {
  description = "The CPU request"
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "The memory request"
  type        = string
  default     = "128Mi"
}

variable "cpu_limit" {
  description = "The CPU limit"
  type        = string
  default     = "250m"
}

variable "memory_limit" {
  description = "The memory limit"
  type        = string
  default     = "256Mi"
}

variable "image" {
  description = "The image to use for the application"
  type        = string
}

variable "image_pull_policy" {
  description = "The image pull policy"
  type        = string
  default     = "IfNotPresent"
}

# IRSA - OIDC Provider configuration
variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL (without https://)"
  type        = string
}

# SQS Queue ARNs for IRSA permissions
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

# SQS URLs
variable "sqs_production_ready_url" {
  description = "The URL for the production ready queue"
  type        = string
}

variable "sqs_payment_confirmed_url" {
  description = "The URL for the payment confirmed queue"
  type        = string
}

variable "sqs_production_withdrawn_url" {
  description = "The URL for the production withdrawn queue"
  type        = string
}

variable "sqs_production_started_url" {
  description = "The URL for the production started queue"
  type        = string
}
