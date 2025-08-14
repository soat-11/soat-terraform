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

module "route-table" {
  source = "./route-table"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  subnet_ids          = module.subnets.subnet_ids
}

module "eks_role" {
  source = "./kubernets-service-role"

  project_name = var.project
}


module "kubernets_service_role" {
  source = "./kubernets-service-role"

  project_name = var.project
}

module "eks_node_role" {
  source = "./kubernets-node-role"


  project = var.project
}

module "eks_node_group" {
  source     = "./kubernets-node"
  depends_on = [module.eks, module.eks_role]

  cluster_name            = module.eks.cluster_name
  project                 = var.project
  eks_role_arn            = module.eks_role.eks_role_arn
  subnet_ids              = module.subnets.subnet_ids
  node_policy_attachments = module.eks_node_role.eks_node_policy_attachments
}
module "eks" {
  source     = "./kubernets-service"
  depends_on = [module.subnets, module.route-table]

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.subnets.subnet_ids
  project_name       = var.project
  eks_role_arn       = module.eks_role.eks_role_arn
  policy_attachments = module.eks_role.eks_policy_attachments
}


