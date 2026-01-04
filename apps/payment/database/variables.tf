variable "project" {
  description = "The name of the project"
  type        = string
  default     = "payment"
}

variable "backend_bucket" {
  description = "Nome do bucket S3 para remote state"
  type        = string
  default     = "arao-soat-terraform-challenge"
}

variable "db_user" {
  description = "Usuário admin do MongoDB"
  type        = string
}

variable "db_password" {
  description = "Senha do usuário admin do MongoDB"
  type        = string
  sensitive   = true
}
