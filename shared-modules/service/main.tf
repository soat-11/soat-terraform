resource "kubernetes_service" "service" {
  metadata {
    name      = "${var.app_name}-service"
    namespace = var.namespace

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }

  spec {
    type = var.service_type

    selector = {
      app = var.deployment_name
    }

    port {
      port        = var.service_port
      target_port = var.container_port
      protocol    = "TCP"
    }
  }
}

