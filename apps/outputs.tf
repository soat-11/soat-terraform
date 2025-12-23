output "payment_service_name" {
  description = "Payment service name"
  value       = module.payment.service_name
}

output "cart_service_name" {
  description = "Cart service name"
  value       = module.cart.service_name
}

output "admin_service_name" {
  description = "Admin service name"
  value       = module.admin.service_name
}

output "ingress_url" {
  description = "Ingress URL"
  value       = data.kubernetes_service.nginx_lb.status[0].load_balancer[0].ingress[0].hostname
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.api_gateway.rest_api_invoke_url
}

