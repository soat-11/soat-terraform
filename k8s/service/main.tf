resource "kubernetes_service" "soat_api_service" {
  metadata {
    name = "${var.app_name}-service"
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = var.app_name
    }

    port {
      port        = var.service_port
      target_port = var.container_port
    }
  }
}
