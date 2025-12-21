output "ingress_name" {
  description = "The name of the ingress"
  value       = kubernetes_ingress_v1.ingress.metadata[0].name
}

