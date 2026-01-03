provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-soat-local"
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "kind-soat-local"
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway = "http://localhost:4566"
    sqs        = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    iam        = "http://localhost:4566"
  }
}


data "terraform_remote_state" "cloud_base" {
  backend = "local"
  config = {
    path = "${path.module}/../cloud-base-local/terraform.tfstate"
  }
}

locals {
  local_config = {
    # Empty string = accept any host (needed for API Gateway -> NGINX Ingress communication)
    ingress_host     = ""
    k8s_ingress_host = "host.docker.internal" # For LocalStack -> Kind communication
    db_host          = "host.docker.internal"
    mongodb_host     = "host.docker.internal"
  }

  payment_vars = var.payment_vars
}

module "create-payment-queue" {
  source = "../../shared-modules/sqs"

  dlq_name          = "create-payment-queue-dlq"
  queue_name        = "create-payment-queue"
  max_receive_count = 3
}

module "payment-paid-queue" {
  source = "../../shared-modules/sqs"

  dlq_name          = "payment-paid-queue-dlq"
  queue_name        = "payment-paid-queue"
  max_receive_count = 3

  queue_config = {
    visibility_timeout_seconds = 120
  }
}

module "mercado-pago-process-payment-queue" {
  source = "../../shared-modules/sqs"

  dlq_name          = "mercado-pago-process-payment-queue-dlq"
  queue_name        = "mercado-pago-process-payment-queue"
  max_receive_count = 3

  queue_config = {
    visibility_timeout_seconds = 120
  }
}

module "cancel-payment-queue" {
  source = "../../shared-modules/sqs"

  dlq_name          = "cancel-payment-queue-dlq"
  queue_name        = "cancel-payment-queue"
  max_receive_count = 3
}

module "payment" {
  source = "../../apps/payment"

  app_name     = "payment"
  image        = var.payment_image
  ingress_host = local.local_config.ingress_host
  vars         = local.payment_vars

  cpu_request    = "100m"
  memory_request = "256Mi"
  cpu_limit      = "250m"
  memory_limit   = "512Mi"

  min_replicas = 1
  max_replicas = 1
}

# module "cart" {
#   source = "../../apps/cart"

#   app_name     = "cart"
#   image        = var.cart_image
#   ingress_host = local.local_config.ingress_host

#   db_name     = "var.db_name"
#   db_user     = "var.db_user"
#   db_password = "var.db_password"
#   db_host     = local.local_config.db_host
#   db_port     = "var.db_port"
#   app_port    = "var.app_port"

#   cpu_request    = "50m"
#   memory_request = "128Mi"
#   cpu_limit      = "100m"
#   memory_limit   = "256Mi"

#   min_replicas = 1
#   max_replicas = 1
# }

# ----------------------
# API Gateway (same module as production)
# ----------------------
module "api_gateway" {
  source = "../../apps/modules/api-gateway"

  project               = var.project
  region                = "us-east-1"
  is_local              = true
  signup_lambda_arn     = data.terraform_remote_state.cloud_base.outputs.signup_lambda_arn
  signup_function_name  = data.terraform_remote_state.cloud_base.outputs.signup_function_name
  login_lambda_arn      = data.terraform_remote_state.cloud_base.outputs.login_lambda_arn
  login_function_name   = data.terraform_remote_state.cloud_base.outputs.login_function_name
  cognito_user_pool_arn = data.terraform_remote_state.cloud_base.outputs.cognito_user_pool_arn
  eks_nlb_hostname      = local.local_config.k8s_ingress_host
}

output "api_gateway_url" {
  value = module.api_gateway.rest_api_invoke_url
}

