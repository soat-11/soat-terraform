# -----------------------------------------------------------------------------
# IRSA - IAM Role for Service Account
# -----------------------------------------------------------------------------
module "irsa" {
  source = "../../shared-modules/irsa"

  service_name      = var.app_name
  namespace         = "default"
  oidc_provider_arn = var.oidc_provider_arn
  oidc_issuer_url   = var.oidc_issuer_url

  # Queues that this service PRODUCES to
  producer_queue_arns = var.producer_queue_arns

  # Queues that this service CONSUMES from
  consumer_queue_arns = var.consumer_queue_arns

  # Secrets this service can access
  secrets_arns = [module.aws_secrets.secret_arn]
}

# -----------------------------------------------------------------------------
# AWS Secrets Manager - Store ALL configuration (sensitive + dynamic)
# -----------------------------------------------------------------------------
module "aws_secrets" {
  source = "../../shared-modules/aws-secrets"

  app_name = var.app_name
  secret_data = {
    # AWS
    AWS_REGION            = var.aws_region
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key

    # App config
    PORT     = tostring(var.app_port)
    NODE_ENV = "production"

    # PostgreSQL
    DB_HOST     = var.db_host
    DB_PORT     = tostring(var.db_port)
    DB_USERNAME = var.db_user
    DB_PASSWORD = var.db_password
    DB_NAME     = var.db_name

    # SQS URLs
    SQS_ORDER_CREATED_URL        = var.sqs_order_created_url
    SQS_PRODUCTION_STARTED_URL   = var.sqs_production_started_url
    SQS_PRODUCTION_READY_URL     = var.sqs_production_ready_url
    SQS_PRODUCTION_COMPLETED_URL = var.sqs_production_withdrawn_url
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Secret (for non-sensitive + injected configs)
# -----------------------------------------------------------------------------
module "secrets" {
  source = "../../shared-modules/secrets"

  app_name = var.app_name
  secret_data = {
    PORT     = tostring(var.app_port)
    NODE_ENV = "production"

    # PostgreSQL
    DB_HOST     = var.db_host
    DB_PORT     = tostring(var.db_port)
    DB_USERNAME = var.db_user
    DB_PASSWORD = var.db_password
    DB_NAME     = var.db_name

    # AWS credentials (opcional - IRSA é usado se não definido)
    AWS_REGION            = var.aws_region
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key

    # SQS - Producer
    SQS_ORDER_CREATED_URL = var.sqs_order_created_url

    # SQS - Consumer (filas do production)
    SQS_PRODUCTION_STARTED_URL   = var.sqs_production_started_url
    SQS_PRODUCTION_READY_URL     = var.sqs_production_ready_url
    SQS_PRODUCTION_COMPLETED_URL = var.sqs_production_withdrawn_url
  }
}

# -----------------------------------------------------------------------------
# Deployment with IRSA Service Account
# -----------------------------------------------------------------------------
module "deployment" {
  source = "../../shared-modules/deployment"

  app_name             = var.app_name
  image                = var.image
  secret_name          = module.secrets.secret_name
  container_port       = var.app_port
  service_account_name = module.irsa.service_account_name

  cpu_request    = var.cpu_request
  memory_request = var.memory_request
  cpu_limit      = var.cpu_limit
  memory_limit   = var.memory_limit

  depends_on = [module.irsa]
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
  path           = "/order(/|$)(.*)"
  path_type      = "ImplementationSpecific"
  rewrite_target = "/$2"

  depends_on = [module.service]
}

