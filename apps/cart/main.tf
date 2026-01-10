
module "secrets" {
  source = "../../shared-modules/secrets"

  app_name = var.app_name
  secret_data = {
    PORT        = var.app_port
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
    DB_HOST     = var.db_host
    DB_PORT     = var.db_port
    DB_NAME     = var.db_name
  }
}

module "deployment" {
  source = "../../shared-modules/deployment"

  app_name       = var.app_name
  image          = var.image
  replicas       = 1
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
  path           = "/cart(/|$)(.*)"
  path_type      = "ImplementationSpecific"
  rewrite_target = "/$2"

  depends_on = [module.service]
}

