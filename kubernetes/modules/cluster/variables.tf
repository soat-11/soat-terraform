variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "eks_role_arn" {
  description = "ARN do IAM role para o EKS cluster (se vazio, cria um novo)"
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
}
