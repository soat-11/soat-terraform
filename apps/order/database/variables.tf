variable "db_user" {
  description = "Usuário admin do PostgreSQL"
  type        = string
  default     = "order"
}

variable "backend_bucket" {
  description = "Nome do bucket S3 para remote state"
  type        = string
  default     = "arao-soat-terraform-challenge"
}

variable "db_password" {
  description = "Senha do usuário admin do PostgreSQL"
  type        = string
  sensitive   = true
}

