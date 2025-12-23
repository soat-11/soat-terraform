
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-soat-local"
}

provider "helm" {
  kubernetes {
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
    sqs = "http://localhost:4566"
  }
}


locals {
  local_config = {
    ingress_host = "localhost"
    db_host      = "host.docker.internal"
    mongodb_host = "host.docker.internal"
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

