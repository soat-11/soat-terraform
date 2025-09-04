output "secret_name" {
  value = kubernetes_secret.soat_api_secret.metadata[0].name

}
