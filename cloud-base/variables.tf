variable "project" {
  description = "The name of the project"
  type        = string
  default     = "soat-challenge"
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "backend_bucket" {
  description = "The name of the backend bucket"
  type        = string
  default     = "arao-soat-terraform-challenge"
}

# -----------------------------------------------------------------------------
# IAM Role Configuration
# -----------------------------------------------------------------------------
# false (default) = usa LabRole existente (AWS Academy/Labs)
# true = cria roles próprios com policies corretas
variable "create_iam_roles" {
  description = "Se true, cria IAM roles próprios. Se false, usa LabRole existente."
  type        = bool
  default     = false
}

