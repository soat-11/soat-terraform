# -----------------------------------------------------------------------------
# App Config
# -----------------------------------------------------------------------------
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "cart"
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
  description = "Image pull policy: Always, IfNotPresent, or Never"
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

# -----------------------------------------------------------------------------
# Database (MongoDB)
# -----------------------------------------------------------------------------
variable "mongodb_uri" {
  description = "MongoDB connection URI"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 27017
}
