variable "db_user" {
  description = "The name of the project"
  type        = string
  default     = "cart"
}

variable "backend_bucket" {
  description = "Nome do bucket S3 para remote state"
  type        = string
  default     = "arao-soat-terraform-challenge"
}

variable "db_password" {
  description = "Usuário admin do MongoDB"
  type        = string
}
