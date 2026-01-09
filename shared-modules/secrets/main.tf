resource "kubernetes_secret" "secret" {
  metadata {
    name      = "${var.app_name}-secret"
    namespace = var.namespace
  }
  type = "Opaque"
  data = var.secret_data
}

