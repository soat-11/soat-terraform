
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.13.1"
  namespace        = "ingress-nginx"
  create_namespace = true
}

resource "null_resource" "wait_lb" {
  depends_on = [helm_release.ingress_nginx]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

data "kubernetes_service" "nginx_lb" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [null_resource.wait_lb]
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
