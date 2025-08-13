variable "region_a" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "region_b" {
  description = "Secondary AWS region"
  type        = string
  default     = "us-west-2"

}


variable "vpc_id" {
  description = "VPC ID for the subnets"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the subnets"
  type        = string
}
