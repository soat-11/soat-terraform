variable "project" {
  description = "The name of the project"
  type        = string
}

variable "database_subnet_id" {
  description = "The ID of the database subnet"
  type        = string
}

variable "db_user" {
  description = "The user for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
