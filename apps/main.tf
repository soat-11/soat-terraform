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

# OIDC outputs for IRSA (used by app modules)
locals {
  oidc_provider_arn = data.terraform_remote_state.kubernetes.outputs.oidc_provider_arn
  oidc_issuer_url   = data.terraform_remote_state.kubernetes.outputs.oidc_issuer_url
}

# All SQS queue ARNs - all services can communicate with all queues
locals {
  all_sqs_queue_arns = [
    # Payment queues
    module.payment_sqs.create-payment-queue_arn,
    module.payment_sqs.payment-paid-queue_arn,
    module.payment_sqs.mercado-pago-process-payment-queue_arn,
    module.payment_sqs.cancel-payment-queue_arn,
    # Order queues
    module.order_sqs.sqs_order_created_arn,
    # Production queues
    module.production_sqs.sqs_payment_confirmed_arn,
    module.production_sqs.sqs_production_started_arn,
    module.production_sqs.sqs_production_ready_arn,
    module.production_sqs.sqs_production_withdrawn_arn,
  ]
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

# -----------------------------------------------------------------------------
# External Secrets Operator for AWS Secrets Manager integration
# -----------------------------------------------------------------------------
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.10.0"
  namespace        = "external-secrets"
  create_namespace = true

  depends_on = [helm_release.ingress_nginx]
}

# Wait for External Secrets Operator CRDs to be ready
resource "time_sleep" "wait_for_eso_crds" {
  depends_on      = [helm_release.external_secrets]
  create_duration = "30s"
}

# ClusterSecretStore for AWS Secrets Manager
# Uses IRSA for authentication (pods with proper service account will have access)
resource "kubernetes_manifest" "cluster_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets-manager"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
        }
      }
    }
  }

  depends_on = [time_sleep.wait_for_eso_crds]
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

  # IRSA configuration
  oidc_provider_arn = local.oidc_provider_arn
  oidc_issuer_url   = local.oidc_issuer_url

  # All queues - full access to send and receive from all queues
  producer_queue_arns = local.all_sqs_queue_arns
  consumer_queue_arns = local.all_sqs_queue_arns

  # AWS credentials
  aws_region            = var.region
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key

  # SQS URLs
  sqs_create_payment_url               = var.sqs_create_payment_url
  sqs_payment_paid_url                 = module.payment_sqs.payment-paid-queue_url
  sqs_mercado_pago_process_payment_url = module.payment_sqs.mercado-pago-process-payment-queue_url
  sqs_cancel_payment_url               = module.payment_sqs.cancel-payment-queue_url

  # Database
  mongodb_uri = local.payment_db_uri
  db_host     = local.payment_db_host

  # External services
  cart_api_url = "http://${module.cart.service_name}:${module.cart.service_port}"

  # Mercado Pago
  mercado_pago_pos_id               = var.mercado_pago_pos_id
  mercado_pago_api_url              = var.mercado_pago_api_url
  mercado_pago_payment_access_token = var.mercado_pago_payment_access_token
  mercado_pago_webhook_secret_key   = var.mercado_pago_webhook_secret_key

  depends_on = [helm_release.ingress_nginx, helm_release.external_secrets]
}

module "cart" {
  source = "./cart"

  app_name     = "cart"
  image        = var.cart_image != "" ? var.cart_image : "${data.terraform_remote_state.cloud_base.outputs.cart_ecr_url}:latest"
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  # IRSA configuration
  oidc_provider_arn = local.oidc_provider_arn
  oidc_issuer_url   = local.oidc_issuer_url

  # All queues - full access to send and receive from all queues
  producer_queue_arns = local.all_sqs_queue_arns
  consumer_queue_arns = local.all_sqs_queue_arns

  # AWS credentials
  aws_region            = var.region
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key

  # MongoDB
  mongodb_uri = local.cart_db_uri
  db_host     = local.cart_db_host
  db_name     = local.cart_db_name
  db_user     = local.cart_db_user
  db_password = local.cart_db_password
  db_port     = 27017

  depends_on = [helm_release.ingress_nginx, helm_release.external_secrets]
}

module "production" {
  source = "./production"

  app_name     = "production"
  image        = var.production_image != "" ? var.production_image : "${data.terraform_remote_state.cloud_base.outputs.production_ecr_url}:latest"
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  # IRSA configuration
  oidc_provider_arn = local.oidc_provider_arn
  oidc_issuer_url   = local.oidc_issuer_url

  # All queues - full access to send and receive from all queues
  producer_queue_arns = local.all_sqs_queue_arns
  consumer_queue_arns = local.all_sqs_queue_arns

  # AWS credentials
  aws_region            = var.region
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key

  # SQS URLs
  sqs_payment_confirmed_url    = module.production_sqs.sqs_payment_confirmed_url
  sqs_production_started_url   = module.production_sqs.sqs_production_started_url
  sqs_production_ready_url     = module.production_sqs.sqs_production_ready_url
  sqs_production_withdrawn_url = module.production_sqs.sqs_production_withdrawn_url

  # MongoDB
  mongo_uri = local.production_db_uri

  depends_on = [helm_release.external_secrets]
}

module "order" {
  source = "./order"

  app_name     = "order"
  image        = var.order_image != "" ? var.order_image : "${data.terraform_remote_state.cloud_base.outputs.order_ecr_url}:latest"
  ingress_host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname

  # IRSA configuration
  oidc_provider_arn = local.oidc_provider_arn
  oidc_issuer_url   = local.oidc_issuer_url

  # All queues - full access to send and receive from all queues
  producer_queue_arns = local.all_sqs_queue_arns
  consumer_queue_arns = local.all_sqs_queue_arns

  # AWS credentials
  aws_region            = var.region
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key

  # PostgreSQL
  db_host     = local.order_db_host
  db_port     = local.order_db_port
  db_name     = local.order_db_name
  db_user     = local.order_db_user
  db_password = local.order_db_password

  # SQS URLs
  sqs_order_created_url        = module.order_sqs.sqs_order_created_url
  sqs_production_started_url   = module.production_sqs.sqs_production_started_url
  sqs_production_ready_url     = module.production_sqs.sqs_production_ready_url
  sqs_production_withdrawn_url = module.production_sqs.sqs_production_withdrawn_url

  depends_on = [helm_release.external_secrets]
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
