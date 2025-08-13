module "provider" {
  source = "./provider"

  region = var.region
}

module "vpc" {
  source = "./vpc"
}

module "bucket" {
  source = "./bucket"

  project = var.project
}

module "subnets" {
  source     = "./subnets"
  depends_on = [module.vpc]

  cidr_block = module.vpc.vpc_cidr_block
  vpc_id     = module.vpc.vpc_id
}

module "internet_gateway" {
  source = "./internet-gateway"
  vpc_id = module.vpc.vpc_id

  depends_on = [module.vpc]
}
