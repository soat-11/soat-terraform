variable "service_name" {
  description = "Name of the service (used for naming IAM role and service account)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
  default     = "default"
}

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
  description = "List of SQS queue ARNs that this service can receive/delete messages from"
  type        = list(string)
  default     = []
}

variable "secrets_arns" {
  description = "List of AWS Secrets Manager secret ARNs that this service can access"
  type        = list(string)
  default     = []
}
