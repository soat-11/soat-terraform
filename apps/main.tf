data "aws_caller_identity" "current" {}

provider "aws" {
  region  = var.region
  profile = "soat"
}

data "terraform_remote_state" "cloud_base" {
  backend = "s3"
  config = {
    bucket  = "soat-terraform-challenge"
    key     = "cloud-base/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}

data "terraform_remote_state" "kubernetes" {
  backend = "s3"
  config = {
    bucket  = "soat-terraform-challenge"
    key     = "kubernetes/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
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
  kubernetes {
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

module "payment" {
  source = "./payment"

  app_name     = "payment"
  image        = var.payment_image != "" ? var.payment_image : data.terraform_remote_state.cloud_base.outputs.repository_url
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  vars = merge(var.payment_vars, {
    AWS_SQS_CREATE_PAYMENT_QUEUE_URL               = module.payment_sqs.create-payment-queue_url
    AWS_SQS_PAYMENT_PAID_QUEUE_URL                 = module.payment_sqs.payment-paid-queue_url
    AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL = module.payment_sqs.mercado-pago-process-payment-queue_url
    AWS_SQS_CANCEL_PAYMENT_QUEUE_URL               = module.payment_sqs.cancel-payment-queue_url
  })

  depends_on = [helm_release.ingress_nginx]
}

module "cart" {
  source = "./cart"

  app_name     = "cart"
  image        = var.cart_image != "" ? var.cart_image : data.terraform_remote_state.cloud_base.outputs.repository_url
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  db_name     = "var.db_name"
  db_user     = "var.cart_vars.DB_USER"
  db_password = "var.cart_vars.DB_PASSWORD"
  db_host     = "var.cart_vars.DB_HOST"
  db_port     = "var.cart_vars.DB_PORT"
  app_port    = "var.cart_vars.PORT"

  depends_on = [helm_release.ingress_nginx]
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

