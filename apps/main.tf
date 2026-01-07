data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region

}

data "terraform_remote_state" "cloud_base" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "cloud-base/terraform.tfstate"
    region = "us-east-1"

  }
}

data "terraform_remote_state" "kubernetes" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "kubernetes/terraform.tfstate"
    region = "us-east-1"
  }
}

# Remote state do banco de dados MongoDB
data "terraform_remote_state" "payment_database" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "apps/payment/database/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cart_database" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "apps/cart/database/terraform.tfstate"
    region = "us-east-1"
  }
}

# MongoDB URI construída automaticamente
locals {
  mongo_host = data.terraform_remote_state.payment_database.outputs.mongo_private_ip
  mongo_uri  = "mongodb://${var.mongo_user}:${var.mongo_password}@${local.mongo_host}:27017/payment?authSource=admin"

  mongo_host_cart        = data.terraform_remote_state.cart_database.outputs.private_ip
  mongo_db_name_cart     = data.terraform_remote_state.cart_database.outputs.mongo_db_name
  mongo_db_user_cart     = data.terraform_remote_state.cart_database.outputs.mongo_db_user
  mongo_db_password_cart = data.terraform_remote_state.cart_database.outputs.mongo_db_password
  mongo_db_host_cart     = data.terraform_remote_state.cart_database.outputs.private_ip
  mongo_db_port_cart     = 27017

}

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
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

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

module "payment_sqs" {
  source = "./payment/sqs"

}

module "payment_ecr" {
  source = "../cloud-base/modules/container-registry"

  repository_name = "payment"
}

module "cart_ecr" {
  source = "../cloud-base/modules/container-registry"

  repository_name = "cart"
}

module "payment" {
  source = "./payment"

  app_name     = "payment"
  image        = var.payment_image != "" ? var.payment_image : "${module.payment_ecr.repository_url}:latest"
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname
  vars = merge(var.payment_vars, {
    AWS_SQS_CREATE_PAYMENT_QUEUE_URL               = module.payment_sqs.create-payment-queue_url
    AWS_SQS_PAYMENT_PAID_QUEUE_URL                 = module.payment_sqs.payment-paid-queue_url
    AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL = module.payment_sqs.mercado-pago-process-payment-queue_url
    AWS_SQS_CANCEL_PAYMENT_QUEUE_URL               = module.payment_sqs.cancel-payment-queue_url
    MONGODB_URI                                    = local.mongo_uri
    DB_HOST                                        = local.mongo_host
  })

  depends_on = [helm_release.ingress_nginx]
}

module "cart" {
  source = "./cart"

  app_name     = "cart"
  image        = var.cart_image != "" ? var.cart_image : "${module.cart_ecr.repository_url}:latest"
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  db_host     = local.mongo_db_host_cart
  db_name     = local.mongo_db_name_cart
  db_password = local.mongo_db_password_cart
  db_port     = local.mongo_db_port_cart
  db_user     = local.mongo_db_user_cart
}

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

