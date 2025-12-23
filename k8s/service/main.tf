resource "kubernetes_service" "soat_api_service" {
  metadata {
    name = "${var.app_name}-service"

     annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
      # "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
    }
  }

  spec {
    type = "LoadBalancer"

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
