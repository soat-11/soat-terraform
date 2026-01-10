# ----------------------
# Production Microservice
# ----------------------

module "secrets" {
  source = "../../shared-modules/secrets"

  app_name = var.app_name
  secret_data = {
    MONGO_URI  = var.mongo_uri
    PORT       = tostring(var.app_port)
    AWS_REGION = var.aws_region

    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key

    SQS_PRODUCTION_READY_URL     = var.sqs_production_ready_url
    SQS_PAYMENT_CONFIRMED_URL    = var.sqs_payment_confirmed_url
    SQS_PRODUCTION_STARTED_URL   = var.sqs_production_started_url
    SQS_PRODUCTION_WITHDRAWN_URL = var.sqs_production_withdrawn_url
  }
}

module "deployment" {
  source = "../../shared-modules/deployment"

  app_name       = var.app_name
  image          = var.image
  secret_name    = module.secrets.secret_name
  container_port = var.app_port


  cpu_request    = var.cpu_request
  memory_request = var.memory_request
  cpu_limit      = var.cpu_limit
  memory_limit   = var.memory_limit
}

module "service" {
  source = "../../shared-modules/service"

  app_name        = var.app_name
  deployment_name = module.deployment.deployment_name
  service_port    = 80
  container_port  = module.deployment.deployment_port
}

module "hpa" {
  source = "../../shared-modules/hpa"

  app_name        = var.app_name
  deployment_name = module.deployment.deployment_name
  min_replicas    = var.min_replicas
  max_replicas    = var.max_replicas

  depends_on = [module.deployment]
}

module "ingress" {
  source = "../../shared-modules/ingress"

  app_name       = var.app_name
  service_name   = module.service.service_name
  service_port   = module.service.service_port
  host           = var.ingress_host
  path           = "/production(/|$)(.*)"
  path_type      = "ImplementationSpecific"
  rewrite_target = "/$2"

  depends_on = [module.service]
}

