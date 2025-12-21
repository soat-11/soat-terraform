data "aws_caller_identity" "current" {}

provider "aws" {
  region  = var.region
  profile = "soat"
}

# ----------------------
# Remote State - Cloud Base
# ----------------------
data "terraform_remote_state" "cloud_base" {
  backend = "s3"
  config = {
    bucket  = "soat-terraform-challenge"
    key     = "cloud-base/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}

# ----------------------
# EKS Cluster
# ----------------------
module "eks_cluster" {
  source = "./modules/cluster"

  vpc_id             = data.terraform_remote_state.cloud_base.outputs.vpc_id
  subnet_ids         = data.terraform_remote_state.cloud_base.outputs.subnet_ids
  project_name       = var.project
  eks_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  security_group_ids = data.terraform_remote_state.cloud_base.outputs.security_group_ids
}

# ----------------------
# EKS Node Group (Spot Instances)
# ----------------------
module "eks_node_group" {
  source     = "./modules/node"
  depends_on = [module.eks_cluster]

  cluster_name = module.eks_cluster.cluster_name
  project      = var.project
  eks_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  subnet_ids   = data.terraform_remote_state.cloud_base.outputs.subnet_ids
}

# ----------------------
# EKS Access Entry
# ----------------------
resource "aws_eks_access_entry" "access_entry" {
  cluster_name      = module.eks_cluster.cluster_name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"
  kubernetes_groups = ["group-soat"]
  type              = "STANDARD"

  depends_on = [module.eks_node_group]
}

resource "aws_eks_access_policy_association" "eks_access_policy" {
  cluster_name  = module.eks_cluster.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.access_entry]
}

# ----------------------
# Kubernetes & Helm Providers
# ----------------------
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
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

# ----------------------
# Metrics Server
# ----------------------
module "metrics" {
  source = "./modules/metrics"

  depends_on = [module.eks_node_group, module.eks_cluster]
}

