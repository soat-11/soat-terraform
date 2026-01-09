data "aws_availability_zones" "available" {}

# -----------------------------------------------------------------------------
# Subnets Públicas - Apps/EKS
# -----------------------------------------------------------------------------
resource "aws_subnet" "subnet_main" {
  count                   = 2
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet-main-${count.index}"
    Type = "application"
  }
}

# -----------------------------------------------------------------------------
# Subnet Dedicada - Databases
# -----------------------------------------------------------------------------
# Subnet pública dedicada para bancos de dados
# Segurança garantida pelo Security Group (aceita apenas tráfego da VPC)
resource "aws_subnet" "database" {
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 10) # 10.0.10.0/24
  map_public_ip_on_launch = false                             # Sem IP público automático
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "subnet-database"
    Type = "database"
  }
}

