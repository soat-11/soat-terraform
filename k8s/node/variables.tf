variable "project" {
  description = "Project name"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "eks_role_arn" {
  description = "EKS Role ARN"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS Node Group"
  type        = list(string)
}

variable "node_policy_attachments" {
  description = "EKS Node Group IAM Policy Attachments"
  type        = list(string)
  default     = []
}


variable "instance_types" {
  description = "Instance types for the EKS Node Group"
  type        = list(string)
  default     = ["t3.medium"]

}
