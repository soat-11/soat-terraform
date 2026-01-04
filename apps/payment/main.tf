
module "secrets" {
  source = "../../shared-modules/secrets"

  app_name    = var.app_name
  secret_data = var.vars
}

module "deployment" {
  source = "../../shared-modules/deployment"

  app_name          = var.app_name
  image             = var.image
  image_pull_policy = var.image_pull_policy
  secret_name       = module.secrets.secret_name
  container_port    = var.vars.PORT

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
  path           = "/payment(/|$)(.*)"
  path_type      = "ImplementationSpecific"
  rewrite_target = "/$2"

  depends_on = [module.service]
}

