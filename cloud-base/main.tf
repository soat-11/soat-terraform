data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

# -----------------------------------------------------------------------------
# IAM Role Configuration
# -----------------------------------------------------------------------------
# var.create_iam_roles = false (default) -> usa LabRole
# var.create_iam_roles = true            -> cria roles próprios
locals {
  lab_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  lambda_role_arn = var.create_iam_roles ? "" : local.lab_role_arn
}

# ----------------------
# VPC
# ----------------------
module "vpc" {
  source = "./modules/vpc"
}

# ----------------------
# Subnets
# ----------------------
module "subnets" {
  source     = "./modules/subnets"
  depends_on = [module.vpc]

  cidr_block = module.vpc.vpc_cidr_block
  vpc_id     = module.vpc.vpc_id
}

# ----------------------
# Internet Gateway
# ----------------------
module "internet_gateway" {
  source     = "./modules/internet-gateway"
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]
}

# ----------------------
# Route Table
# ----------------------
module "route_table" {
  source = "./modules/route-table"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  subnet_ids          = module.subnets.subnet_ids
}

# ----------------------
# Security Group
# ----------------------
module "security_group" {
  source  = "./modules/security-group"
  project = var.project
  vpc_id  = module.vpc.vpc_id
}

# ----------------------
# Container Registry (ECR)
# ----------------------
module "container_registry" {
  source          = "./modules/container-registry"
  repository_name = "${var.project}-repository"
}

# ----------------------
# S3 Bucket
# ----------------------
module "bucket" {
  source  = "./modules/bucket"
  project = var.project
}

# ----------------------
# Cognito
# ----------------------
module "cognito" {
  source = "./modules/cognito"
}

# ----------------------
# Lambda Functions
# ----------------------
module "lambda" {
  source   = "./modules/lambda"
  project  = var.project
  role_arn = local.lambda_role_arn
}

