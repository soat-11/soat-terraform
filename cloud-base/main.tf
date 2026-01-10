data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

# var.create_iam_roles = false (default) -> usa LabRole
# var.create_iam_roles = true -> cria roles próprios
locals {
  lab_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  lambda_role_arn = var.create_iam_roles ? "" : local.lab_role_arn
}

module "vpc" {
  source = "./modules/vpc"
}

module "subnets" {
  source     = "./modules/subnets"
  depends_on = [module.vpc]

  cidr_block = module.vpc.vpc_cidr_block
  vpc_id     = module.vpc.vpc_id
}

module "internet_gateway" {
  source     = "./modules/internet-gateway"
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]
}

module "route_table" {
  source = "./modules/route-table"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  subnet_ids = concat(
    module.subnets.subnet_ids,
    [module.subnets.database_subnet_id]
  )
}

module "security_group" {
  source  = "./modules/security-group"
  project = var.project
  vpc_id  = module.vpc.vpc_id
}

module "container_registry" {
  source          = "./modules/container-registry"
  repository_name = "${var.project}-repository"
}

module "payment_ecr" {
  source          = "./modules/container-registry"
  repository_name = "payment"
}

module "cart_ecr" {
  source          = "./modules/container-registry"
  repository_name = "cart"
}

module "production_ecr" {
  source          = "./modules/container-registry"
  repository_name = "production"
}

module "order_ecr" {
  source          = "./modules/container-registry"
  repository_name = "order"
}

module "bucket" {
  source  = "./modules/bucket"
  project = var.project
}

module "cognito" {
  source = "./modules/cognito"
}

module "lambda" {
  source   = "./modules/lambda"
  project  = var.project
  role_arn = local.lambda_role_arn

  cognito_user_pool_id  = module.cognito.user_pool_id
  cognito_app_client_id = module.cognito.app_client_id

  depends_on = [module.cognito]
}
