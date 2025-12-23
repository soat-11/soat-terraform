resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = var.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = var.rewrite_target
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.host

      http {
        path {
          path      = var.path
          path_type = var.path_type

          backend {
            service {
              name = var.service_name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }
}

