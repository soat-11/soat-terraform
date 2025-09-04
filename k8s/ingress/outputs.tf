output "url" {
  value = "http://${data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname}"
}
