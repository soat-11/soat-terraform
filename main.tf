data "aws_caller_identity" "current" {}

module "provider" {
  source = "./provider"
  region = var.region
}

module "container_registry" {
  source          = "./container-registry"
  repository_name = "${var.project}-repository"
}

module "vpc" {
  source = "./vpc"
}

module "bucket" {
  source  = "./bucket"
  project = var.project
}

module "subnets" {
  source     = "./subnets"
  depends_on = [module.vpc]

  cidr_block = module.vpc.vpc_cidr_block
  vpc_id     = module.vpc.vpc_id
}

module "internet_gateway" {
  source     = "./internet-gateway"
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]
}

module "route-table" {
  source = "./route-table"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  subnet_ids          = module.subnets.subnet_ids
}

module "security_group" {
  source  = "./security-group"
  project = var.project
  vpc_id  = module.vpc.vpc_id
}

# Cluster com LabRole
module "eks_service" {
  source     = "./k8s/cluster"
  depends_on = [module.subnets, module.route-table]

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.subnets.subnet_ids
  project_name       = var.project
  eks_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  security_group_ids = module.security_group.security_group_ids
}

# Node group com LabRole
module "eks_node_group" {
  source     = "./k8s/node"
  depends_on = [module.eks_service]

  cluster_name = module.eks_service.cluster_name
  project      = var.project
  eks_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  subnet_ids   = module.subnets.subnet_ids
}

resource "aws_eks_access_entry" "access_entry" {
  cluster_name      = module.eks_service.cluster_name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"
  kubernetes_groups = ["group-soat"]
  type              = "STANDARD"

  depends_on = [module.eks_node_group]
}

resource "aws_eks_access_policy_association" "eks_access_policy" {
  cluster_name  = module.eks_service.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.access_entry]
}

data "aws_eks_cluster" "eks" {
  name       = module.eks_service.cluster_name
  depends_on = [module.eks_service]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks_service.cluster_name
  depends_on = [module.eks_service]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

output "principal_arn" {
  value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"
}


module "database-sg" {
  source = "./database-sg"
  vpc_id = module.vpc.vpc_id
}

module "database-subnet" {
  source     = "./database-subnet"
  depends_on = [module.subnets, module.route-table]

  subnet_ids = module.subnets.subnet_ids

}

module "database" {
  source               = "./database"
  depends_on           = [module.subnets, module.route-table]
  password             = var.db_password
  db_subnet_group_name = module.database-subnet.database_subnet_group_name
  security_group_ids   = [module.database-sg.rds_security_group_id]
}


module "secrets" {
  source = "./k8s/secrets"

  db_name                      = module.database.db_name
  db_user                      = module.database.db_user
  db_password                  = module.database.db_password
  db_port                      = module.database.db_port
  db_host                      = module.database.db_host
  app_port                     = var.app_port
  app_base_url                 = "/"
  payment_access_token         = var.payment_access_token
  payment_api_url              = var.payment_api_url
  payment_user_id              = var.payment_user_id
  payment_pos_id               = var.payment_pos_id
  webhook_secret_signature_key = var.webhook_secret_signature_key
  webhook_api_url              = "/"
}

module "deployment" {
  source = "./k8s/deployment"

  app_name    = var.project
  image       = module.container_registry.repository_url
  secret_name = module.secrets.secret_name
  depends_on  = [module.eks_node_group, module.eks_service, module.database, module.secrets]
}


module "service" {
  source = "./k8s/service"

  app_name       = var.project
  deployment     = module.deployment.deployment_name
  service_port   = 5000
  container_port = var.app_port
  depends_on     = [module.deployment]
}

module "ingress" {
  source = "./k8s/ingress"

  app_name     = var.project
  service_name = module.service.service_name
  service_port = module.service.service_port
  depends_on   = [module.service]
}
