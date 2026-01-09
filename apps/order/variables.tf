variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "app_port" {
  description = "The port for the application"
  type        = number
  default     = 3000
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
  default     = "order"
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

# PostgreSQL
variable "db_host" {
  description = "PostgreSQL host"
  type        = string
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "db_user" {
  description = "PostgreSQL user"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

# SQS
variable "sqs_order_created_url" {
  description = "The URL for the order created queue (producer)"
  type        = string
}

variable "sqs_production_started_url" {
  description = "The URL for the production started queue (consumer)"
  type        = string
}

variable "sqs_production_ready_url" {
  description = "The URL for the production ready queue (consumer)"
  type        = string
}

variable "sqs_production_withdrawn_url" {
  description = "The URL for the production withdrawn/completed queue (consumer)"
  type        = string
}

# AWS Credentials
variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

