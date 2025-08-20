output "api_image_full" {
  value = kubernetes_deployment.kubernetes_deployment.spec[0].template[0].spec[0].container[0].image
}
