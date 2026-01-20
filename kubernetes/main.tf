data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

# var.create_iam_roles = false (default) -> usa LabRole
# var.create_iam_roles = true -> cria roles próprios
locals {
  lab_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  eks_role_arn = var.create_iam_roles ? "" : local.lab_role_arn
}

data "terraform_remote_state" "cloud_base" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "cloud-base/terraform.tfstate"
    region = "us-east-1"
  }
}

module "eks_cluster" {
  source = "./modules/cluster"

  vpc_id             = data.terraform_remote_state.cloud_base.outputs.vpc_id
  subnet_ids         = data.terraform_remote_state.cloud_base.outputs.subnet_ids
  project_name       = var.project
  eks_role_arn       = local.eks_role_arn
  security_group_ids = data.terraform_remote_state.cloud_base.outputs.security_group_ids
}

module "eks_node_group" {
  source     = "./modules/node"
  depends_on = [module.eks_cluster]

  cluster_name = module.eks_cluster.cluster_name
  project      = var.project
  eks_role_arn = local.eks_role_arn
  subnet_ids   = data.terraform_remote_state.cloud_base.outputs.subnet_ids


  instance_types = ["t3.small", "t3a.small"]
  desired_size   = 3
  min_size       = 2
  max_size       = 4
}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

locals {
  access_principal_arn = var.create_iam_roles ? data.aws_iam_session_context.current.issuer_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"
}

resource "aws_eks_access_entry" "access_entry" {
  cluster_name      = module.eks_cluster.cluster_name
  principal_arn     = local.access_principal_arn
  kubernetes_groups = ["group-soat"]
  type              = "STANDARD"

  depends_on = [module.eks_node_group]
}

resource "aws_eks_access_policy_association" "eks_access_policy" {
  cluster_name  = module.eks_cluster.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = local.access_principal_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.access_entry]
}

data "aws_eks_cluster" "eks" {
  name       = module.eks_cluster.cluster_name
  depends_on = [module.eks_cluster]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks_cluster.cluster_name
  depends_on = [module.eks_cluster]
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

module "metrics" {
  source = "./modules/metrics"

  depends_on = [module.eks_node_group, module.eks_cluster]
}
