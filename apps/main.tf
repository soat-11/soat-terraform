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

data "terraform_remote_state" "production_database" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "apps/production/database/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "order_database" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "apps/order/database/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  payment_db_host     = data.terraform_remote_state.payment_database.outputs.private_ip
  payment_db_uri      = data.terraform_remote_state.payment_database.outputs.mongo_db_uri
  payment_db_name     = data.terraform_remote_state.payment_database.outputs.mongo_db_name
  payment_db_user     = data.terraform_remote_state.payment_database.outputs.mongo_db_user
  payment_db_password = data.terraform_remote_state.payment_database.outputs.mongo_db_password

  cart_db_host     = data.terraform_remote_state.cart_database.outputs.private_ip
  cart_db_uri      = data.terraform_remote_state.cart_database.outputs.mongo_db_uri
  cart_db_name     = data.terraform_remote_state.cart_database.outputs.mongo_db_name
  cart_db_user     = data.terraform_remote_state.cart_database.outputs.mongo_db_user
  cart_db_password = data.terraform_remote_state.cart_database.outputs.mongo_db_password

  production_db_uri = data.terraform_remote_state.production_database.outputs.mongo_db_uri

  # Order (PostgreSQL)
  order_db_host     = data.terraform_remote_state.order_database.outputs.private_ip
  order_db_port     = data.terraform_remote_state.order_database.outputs.postgres_db_port
  order_db_name     = data.terraform_remote_state.order_database.outputs.postgres_db_name
  order_db_user     = data.terraform_remote_state.order_database.outputs.postgres_db_user
  order_db_password = data.terraform_remote_state.order_database.outputs.postgres_db_password
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

module "production_sqs" {
  source = "./production/sqs"
}

module "order_sqs" {
  source = "./order/sqs"
}

module "payment" {
  source = "./payment"

  app_name     = "payment"
  image        = var.payment_image != "" ? var.payment_image : "${data.terraform_remote_state.cloud_base.outputs.payment_ecr_url}:latest"
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname
  vars = merge(var.payment_vars, {
    AWS_SQS_CREATE_PAYMENT_QUEUE_URL               = module.payment_sqs.create-payment-queue_url
    AWS_SQS_PAYMENT_PAID_QUEUE_URL                 = module.payment_sqs.payment-paid-queue_url
    AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL = module.payment_sqs.mercado-pago-process-payment-queue_url
    AWS_SQS_CANCEL_PAYMENT_QUEUE_URL               = module.payment_sqs.cancel-payment-queue_url
    MONGODB_URI                                    = local.payment_db_uri
    DB_HOST                                        = local.payment_db_host
    CART_API_URL                                   = "http://${module.cart.service_name}:${module.cart.service_port}"
  })


  depends_on = [helm_release.ingress_nginx]
}

module "cart" {
  source = "./cart"

  app_name     = "cart"
  image        = var.cart_image != "" ? var.cart_image : "${data.terraform_remote_state.cloud_base.outputs.cart_ecr_url}:latest"
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  db_host     = local.cart_db_host
  db_name     = local.cart_db_name
  db_password = local.cart_db_password
  db_port     = 27017
  db_user     = local.cart_db_user
}

module "production" {
  source = "./production"

  app_name                     = "production"
  image                        = var.production_image != "" ? var.production_image : "${data.terraform_remote_state.cloud_base.outputs.production_ecr_url}:latest"
  ingress_host                 = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname
  sqs_payment_confirmed_url    = module.production_sqs.sqs_payment_confirmed_url
  sqs_production_started_url   = module.production_sqs.sqs_production_started_url
  sqs_production_ready_url     = module.production_sqs.sqs_production_ready_url
  sqs_production_withdrawn_url = module.production_sqs.sqs_production_withdrawn_url
  mongo_uri                    = local.production_db_uri
  aws_access_key_id            = var.production_vars.AWS_ACCESS_KEY_ID
  aws_secret_access_key        = var.production_vars.AWS_SECRET_ACCESS_KEY
}

module "order" {
  source = "./order"

  app_name     = "order"
  image        = var.order_image != "" ? var.order_image : "${data.terraform_remote_state.cloud_base.outputs.order_ecr_url}:latest"
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  # PostgreSQL
  db_host     = local.order_db_host
  db_port     = local.order_db_port
  db_name     = local.order_db_name
  db_user     = local.order_db_user
  db_password = local.order_db_password

  # SQS - Producer
  sqs_order_created_url = module.order_sqs.sqs_order_created_url

  # SQS - Consumer (filas do production)
  sqs_production_started_url   = module.production_sqs.sqs_production_started_url
  sqs_production_ready_url     = module.production_sqs.sqs_production_ready_url
  sqs_production_withdrawn_url = module.production_sqs.sqs_production_withdrawn_url

  # AWS Credentials
  aws_access_key_id     = var.order_vars.AWS_ACCESS_KEY_ID
  aws_secret_access_key = var.order_vars.AWS_SECRET_ACCESS_KEY
}

module "api_gateway" {
  source = "./modules/api-gateway"

  project                        = var.project
  region                         = var.region
  anonymous_login_lambda_arn     = data.terraform_remote_state.cloud_base.outputs.login_lambda_arn
  anonymous_login_function_name  = data.terraform_remote_state.cloud_base.outputs.login_function_name
  signup_and_login_lambda_arn    = data.terraform_remote_state.cloud_base.outputs.signup_lambda_arn
  signup_and_login_function_name = data.terraform_remote_state.cloud_base.outputs.signup_function_name
  cognito_user_pool_arn          = data.terraform_remote_state.cloud_base.outputs.cognito_user_pool_arn
  eks_nlb_hostname               = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  depends_on = [helm_release.ingress_nginx]
}
