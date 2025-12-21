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
# Remote State - Kubernetes
# ----------------------
data "terraform_remote_state" "kubernetes" {
  backend = "s3"
  config = {
    bucket  = "soat-terraform-challenge"
    key     = "kubernetes/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}

# ----------------------
# Kubernetes & Helm Providers
# ----------------------
data "aws_eks_cluster" "eks" {
  name = data.terraform_remote_state.kubernetes.outputs.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = data.terraform_remote_state.kubernetes.outputs.cluster_name
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
# Ingress Controller (shared)
# ----------------------
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.13.1"
  namespace        = "ingress-nginx"
  create_namespace = true
}

data "kubernetes_service" "nginx_lb" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.ingress_nginx]
}

# ----------------------
# Microservices
# ----------------------
module "payment" {
  source = "./payment"

  app_name       = "payment"
  image          = var.payment_image != "" ? var.payment_image : data.terraform_remote_state.cloud_base.outputs.repository_url
  ingress_host   = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname
  
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
  db_host     = var.db_host
  db_port     = var.db_port
  app_port    = var.app_port

  payment_access_token         = var.payment_access_token
  payment_api_url              = var.payment_api_url
  payment_user_id              = var.payment_user_id
  payment_pos_id               = var.payment_pos_id
  webhook_secret_signature_key = var.webhook_secret_signature_key

  depends_on = [helm_release.ingress_nginx]
}

module "cart" {
  source = "./cart"

  app_name     = "cart"
  image        = var.cart_image != "" ? var.cart_image : data.terraform_remote_state.cloud_base.outputs.repository_url
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
  db_host     = var.db_host
  db_port     = var.db_port
  app_port    = var.app_port

  depends_on = [helm_release.ingress_nginx]
}

module "admin" {
  source = "./admin"

  app_name     = "admin"
  image        = var.admin_image != "" ? var.admin_image : data.terraform_remote_state.cloud_base.outputs.repository_url
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
  db_host     = var.db_host
  db_port     = var.db_port
  app_port    = var.app_port

  depends_on = [helm_release.ingress_nginx]
}

# ----------------------
# API Gateway
# ----------------------
module "api_gateway" {
  source = "./modules/api-gateway"

  project               = var.project
  region                = var.region
  signup_lambda_arn     = data.terraform_remote_state.cloud_base.outputs.signup_lambda_arn
  signup_function_name  = data.terraform_remote_state.cloud_base.outputs.signup_function_name
  login_lambda_arn      = data.terraform_remote_state.cloud_base.outputs.login_lambda_arn
  login_function_name   = data.terraform_remote_state.cloud_base.outputs.login_function_name
  cognito_user_pool_arn = data.terraform_remote_state.cloud_base.outputs.cognito_user_pool_arn
  eks_nlb_hostname      = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  depends_on = [helm_release.ingress_nginx]
}

