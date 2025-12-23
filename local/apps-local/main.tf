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

# ----------------------
# Payment Microservice
# ----------------------
module "payment" {
  source = "../../shared-modules/deployment"

  app_name       = "payment"
  image          = var.payment_image
  secret_name    = kubernetes_secret_v1.payment.metadata[0].name
  container_port = var.PORT
}

resource "kubernetes_secret_v1" "payment" {
  metadata {
    name = "payment-secret"
  }
  type = "Opaque"
  data = {
    # Database
    DB_NAME     = var.db_name
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
    DB_HOST     = var.db_host
    DB_PORT     = tostring(var.db_port)

    # MongoDB
    MONGODB_URI = var.MONGODB_URI

    # App
    NODE_ENV = var.NODE_ENV
    PORT     = tostring(var.PORT)

    # AWS/LocalStack
    AWS_REGION            = var.AWS_REGION
    AWS_ENDPOINT          = var.AWS_ENDPOINT
    AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY

    # SQS Queues
    AWS_SQS_CREATE_PAYMENT_QUEUE_URL               = var.AWS_SQS_CREATE_PAYMENT_QUEUE_URL
    AWS_SQS_PAYMENT_PAID_QUEUE_URL                 = var.AWS_SQS_PAYMENT_PAID_QUEUE_URL
    AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL = var.AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL
    AWS_SQS_CANCEL_PAYMENT_QUEUE_URL               = var.AWS_SQS_CANCEL_PAYMENT_QUEUE_URL

    # Mercado Pago
    MERCADO_PAGO_POS_ID               = var.MERCADO_PAGO_POS_ID
    MERCADO_PAGO_API_URL              = var.MERCADO_PAGO_API_URL
    MERCADO_PAGO_PAYMENT_ACCESS_TOKEN = var.MERCADO_PAGO_PAYMENT_ACCESS_TOKEN
    MERCADO_PAGO_WEBHOOK_SECRET_KEY   = var.MERCADO_PAGO_WEBHOOK_SECRET_KEY
  }
}

module "payment_service" {
  source = "../../shared-modules/service"

  app_name        = "payment"
  deployment_name = module.payment.deployment_name
  service_port    = 80
  container_port  = var.PORT
}

# ----------------------
# Cart Microservice
# ----------------------
module "cart" {
  source = "../../shared-modules/deployment"

  app_name       = "cart"
  image          = var.cart_image
  secret_name    = kubernetes_secret_v1.cart.metadata[0].name
  container_port = var.PORT
}

resource "kubernetes_secret_v1" "cart" {
  metadata {
    name = "cart-secret"
  }
  type = "Opaque"
  data = {
    DB_NAME     = var.db_name
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
    DB_HOST     = var.db_host
    DB_PORT     = tostring(var.db_port)
    MONGODB_URI = var.MONGODB_URI
    NODE_ENV    = var.NODE_ENV
    PORT        = tostring(var.PORT)
  }
}

module "cart_service" {
  source = "../../shared-modules/service"

  app_name        = "cart"
  deployment_name = module.cart.deployment_name
  service_port    = 80
  container_port  = var.PORT
}

# ----------------------
# Admin Microservice
# ----------------------
module "admin" {
  source = "../../shared-modules/deployment"

  app_name       = "admin"
  image          = var.admin_image
  secret_name    = kubernetes_secret_v1.admin.metadata[0].name
  container_port = var.PORT
}

resource "kubernetes_secret_v1" "admin" {
  metadata {
    name = "admin-secret"
  }
  type = "Opaque"
  data = {
    DB_NAME     = var.db_name
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
    DB_HOST     = var.db_host
    DB_PORT     = tostring(var.db_port)
    MONGODB_URI = var.MONGODB_URI
    NODE_ENV    = var.NODE_ENV
    PORT        = tostring(var.PORT)
  }
}

module "admin_service" {
  source = "../../shared-modules/service"

  app_name        = "admin"
  deployment_name = module.admin.deployment_name
  service_port    = 80
  container_port  = var.PORT
}

# ----------------------
# Ingress
# ----------------------
resource "kubernetes_ingress_v1" "main" {
  metadata {
    name = "soat-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path      = "/payment"
          path_type = "Prefix"
          backend {
            service {
              name = module.payment_service.service_name
              port {
                number = 80
              }
            }
          }
        }

        path {
          path      = "/cart"
          path_type = "Prefix"
          backend {
            service {
              name = module.cart_service.service_name
              port {
                number = 80
              }
            }
          }
        }

        path {
          path      = "/admin"
          path_type = "Prefix"
          backend {
            service {
              name = module.admin_service.service_name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
