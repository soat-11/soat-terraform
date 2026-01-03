variable "project" {
  description = "Project name"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "eks_role_arn" {
  description = "ARN do IAM role para o Node Group (se vazio, cria um novo)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS Node Group"
  type        = list(string)
}

variable "instance_types" {
  description = "Instance types for the EKS Node Group (multiple for Spot availability)"
  type        = list(string)
  default     = ["t3.small", "t3a.small"]
}

variable "desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 2
}
