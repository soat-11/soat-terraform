# =============================================================================
# MongoDB Module - Variables
# =============================================================================
# Módulo reutilizável para provisionar MongoDB em EC2.
# Encapsula database-ec2 + script de inicialização.
# =============================================================================

variable "project_name" {
  description = "Nome do projeto (usado para naming de recursos)"
  type        = string
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

variable "mongo_version" {
  description = "Versão do MongoDB Docker image"
  type        = string
  default     = "6.0"
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

