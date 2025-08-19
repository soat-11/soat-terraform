resource "kubernetes_deployment" "kubernetes_deployment" {
  metadata {
    name = var.app_name

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
          name  = var.app_name
          image = var.image
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
