variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string

}

variable "eks_role_arn" {
  description = "The ARN of the IAM role to be granted access."
  type        = string
}
