variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  type        = string

}

variable "subnet_ids" {
  type        = list(string)
  description = "Lista de subnets a serem associadas"
}
