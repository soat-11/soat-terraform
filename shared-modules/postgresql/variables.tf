variable "project_name" {
  description = "Nome do projeto (usado para naming de recursos)"
  type        = string
}

variable "db_user" {
  description = "Usuário admin do PostgreSQL"
  type        = string
}

variable "db_password" {
  description = "Senha do usuário admin do PostgreSQL"
  type        = string
  sensitive   = true
}

variable "backend_bucket" {
  description = "Nome do bucket S3 para remote state do cloud-base"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.small"
}

variable "data_volume_size" {
  description = "Tamanho do volume EBS de dados (GB)"
  type        = number
  default     = 20
}

variable "postgres_version" {
  description = "Versão do PostgreSQL Docker image"
  type        = string
  default     = "15-alpine"
}

variable "database_name" {
  description = "Nome do database padrão a ser criado"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags adicionais para os recursos"
  type        = map(string)
  default     = {}
}

