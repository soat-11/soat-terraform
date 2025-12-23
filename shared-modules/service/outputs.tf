output "service_name" {
  description = "The name of the Kubernetes service"
  value       = kubernetes_service.service.metadata[0].name
}

output "service_port" {
  description = "The port on which the service is exposed"
  value       = kubernetes_service.service.spec[0].port[0].port
}

output "nlb_hostname" {
  value = kubernetes_service.soat_api_service.status[0].load_balancer[0].ingress[0].hostname
}
