output "deployment_name" {
  value = kubernetes_deployment.deployment.metadata[0].name
}

output "deployment_port" {
  value = kubernetes_deployment.deployment.spec[0].template[0].spec[0].container[0].port[0].container_port
}
