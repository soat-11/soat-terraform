

output "url" {
  value = kubernetes_ingress_v1.soat_api_ingress.spec[0].rule[0].host
}


