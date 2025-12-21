# ----------------------
# Payment Microservice
# ----------------------

module "secrets" {
  source = "../../shared-modules/secrets"

  app_name = var.app_name
  secret_data = {
    DB_NAME                      = var.db_name
    DB_USER                      = var.db_user
    DB_PASSWORD                  = var.db_password
    DB_PORT                      = tostring(var.db_port)
    DB_HOST                      = var.db_host
    APP_PORT                     = tostring(var.app_port)
    APP_BASE_URL                 = var.app_base_url
    PAYMENT_ACCESS_TOKEN         = var.payment_access_token
    PAYMENT_API_URL              = var.payment_api_url
    PAYMENT_USER_ID              = tostring(var.payment_user_id)
    PAYMENT_POS_ID               = var.payment_pos_id
    WEBHOOK_SECRET_SIGNATURE_KEY = var.webhook_secret_signature_key
    WEBHOOK_API_URL              = var.webhook_api_url
  }
}

module "deployment" {
  source = "../../shared-modules/deployment"

  app_name       = var.app_name
  image          = var.image
  secret_name    = module.secrets.secret_name
  container_port = var.app_port

  # Optimized for lightweight application
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

  app_name     = var.app_name
  service_name = module.service.service_name
  service_port = module.service.service_port
  host         = var.ingress_host
  path         = "/payment"

  depends_on = [module.service]
}

