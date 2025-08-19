module "provider" {
  source = "./provider"

  region = var.region
}

module "container_registry" {
  source = "./container-registry"

  repository_name = "${var.project}-repository"
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

module "eks_service_role" {
  source = "./k8s-service-role"

  project_name = var.project
}


module "eks_node_role" {
  source = "./k8s-node-role"


  project = var.project
}


module "security_group" {
  source = "./security-group"

  project = var.project
  vpc_id  = module.vpc.vpc_id
}


module "eks_service" {
  source = "./k8s-service"
  depends_on = [
    module.subnets, module.route-table,
    module.eks_service_role.eks_policy_attachments,

  ]

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.subnets.subnet_ids
  project_name       = var.project
  eks_role_arn       = module.eks_service_role.eks_role_arn
  security_group_ids = module.security_group.security_group_ids
}



module "eks_node_group" {
  source = "./k8s-node"
  depends_on = [
    module.eks_service,
    module.eks_node_role
  ]

  cluster_name            = module.eks_service.cluster_name
  project                 = var.project
  eks_role_arn            = module.eks_node_role.eks_node_role_arn
  subnet_ids              = module.subnets.subnet_ids
  node_policy_attachments = module.eks_node_role.eks_node_policy_attachments
}


module "access_entry" {
  source = "./access-entry"

  eks_role_arn = module.eks_service.eks_service_role_arn
  cluster_name = module.eks_service.cluster_name
  depends_on   = [module.eks_node_group]
}


data "aws_eks_cluster_auth" "eks" {
  name = module.eks_service.cluster_name
}
data "aws_eks_cluster" "eks" {
  name = module.eks_service.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}





# module "api_deployment" {
#   source = "./k8s-deployment"

#   app_name = "soat-api-deployment"
#   image    = "${module.container_registry.repository_url}:latest"
# }
