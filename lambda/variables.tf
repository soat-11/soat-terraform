variable "project" {
  description = "The name of the project"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role to be used by Lambda functions"
  type        = string
}