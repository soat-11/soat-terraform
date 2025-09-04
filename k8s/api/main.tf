




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



