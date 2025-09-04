output "deployment_name" {
  value = kubernetes_deployment.deployment.metadata[0].name

}
