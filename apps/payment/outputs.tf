output "deployment_name" {
  description = "Deployment name"
  value       = module.deployment.deployment_name
}

output "service_name" {
  description = "Service name"
  value       = module.service.service_name
}

output "service_port" {
  description = "Service port"
  value       = module.service.service_port
}

