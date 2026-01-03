
# Módulo agnóstico para provisionar bancos de dados em EC2 de forma econômica.
# Desacopla infraestrutura (Compute/Storage/Network) da configuração do software.

variable "project_name" {
  description = "Nome do projeto (usado para naming de recursos)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o Security Group será criado"
  type        = string
}

variable "subnet_id" {
  description = "ID da Subnet onde a instância será provisionada (pública ou privada)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2 (t3.small recomendado para dev/test)"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "ID da AMI (Amazon Linux 2 recomendado)"
  type        = string
}

variable "data_volume_size" {
  description = "Tamanho do volume EBS de dados em GB"
  type        = number
  default     = 20
}

variable "data_volume_type" {
  description = "Tipo do volume EBS (gp3 recomendado para custo-benefício)"
  type        = string
  default     = "gp3"
}

variable "db_port" {
  description = "Porta do banco de dados (ex: 27017 para Mongo, 5432 para Postgres)"
  type        = number

}

variable "allowed_cidrs" {
  description = "Lista de CIDRs permitidos para acessar o banco (ex: VPC CIDR ou IP de VPN)"
  type        = list(string)
}

variable "user_data_script" {
  description = "Conteúdo do script de inicialização (deve incluir lógica de montagem do EBS)"
  type        = string
}

variable "key_name" {
  description = "Nome da chave SSH para acesso à instância (opcional)"
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Associar IP público à instância (necessário em subnet pública sem NAT)"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Tamanho do volume root em GB"
  type        = number
  default     = 8
}

variable "tags" {
  description = "Tags adicionais para os recursos"
  type        = map(string)
  default     = {}
}

