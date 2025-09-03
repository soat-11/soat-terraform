resource "kubernetes_deployment" "kubernetes_deployment" {
  metadata {
    name = "${var.app_name}-deployment"

  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }
      spec {
        container {
          name              = var.app_name
          image             = var.image
          image_pull_policy = "Always"
          port {
            container_port = var.container_port
            name           = "http"
            protocol       = "TCP"
          }
          env_from {
            secret_ref {
              name = var.secret_name
            }
          }

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }
        }
      }
    }
  }

}


resource "kubernetes_service" "soat_api_service" {
  metadata {
    name = "${var.app_name}-service"
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "${var.app_name}-deployment"
    }

    port {
      port        = 5000
      target_port = 3010
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "soat_api_hpa" {
  metadata {
    name = "soat-api-hpa"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "${var.app_name}-deployment"
    }

    min_replicas = 1
    max_replicas = 3

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
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
}


resource "kubernetes_ingress_v1" "soat_api_ingress" {
  metadata {
    name = "${var.app_name}-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname


      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.soat_api_service.metadata[0].name
              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}

# resource "kubernetes_horizontal_pod_autoscaler_v2" "soat_nginx_hpa" {
#   metadata {
#     name      = "${var.app_name}-nginx-hpa"
#     namespace = "ingress-nginx"
#   }

#   spec {
#     scale_target_ref {
#       api_version = "apps/v1"
#       kind        = "Deployment"
#       name        = "ingress-nginx-controller"
#     }

#     min_replicas = 1
#     max_replicas = 8

#     metric {
#       type = "Resource"
#       resource {
#         name = "cpu"
#         target {
#           type                = "Utilization"
#           average_utilization = 50
#         }
#       }
#     }

#     metric {
#       type = "Resource"
#       resource {
#         name = "memory"
#         target {
#           type                = "Utilization"
#           average_utilization = 50
#         }
#       }
#     }
#   }
# }
resource "kubernetes_secret" "soat_api_secret" {
  metadata {
    name = "soat-api-secret"
  }
  type = "Opaque"
  data = {
    DB_NAME                      = "ZXhhbXBsZQ=="
    DB_USER                      = "ZXhhbXBsZQ=="
    DB_PASSWORD                  = "ZXhhbXBsZQ=="
    DB_PORT                      = "ZXhhbXBsZQ=="
    DB_HOST                      = "ZXhhbXBsZQ=="
    APP_PORT                     = "ZXhhbXBsZQ=="
    APP_BASE_URL                 = "ZXhhbXBsZQ=="
    PAYMENT_ACCESS_TOKEN         = "ZXhhbXBsZQ=="
    PAYMENT_API_URL              = "ZXhhbXBsZQ=="
    PAYMENT_USER_ID              = "ZXhhbXBsZQ=="
    PAYMENT_POS_ID               = "ZXhhbXBsZQ=="
    WEBHOOK_SECRET_SIGNATURE_KEY = "ZXhhbXBsZQ=="
    WEBHOOK_API_URL              = "ZXhhbXBsZQ=="
  }
}


