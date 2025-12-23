# Outputs for local testing

output "api_gateway_id" {
  value       = module.api_gateway.rest_api_id
  description = "API Gateway REST API ID"
}

output "api_gateway_invoke_url" {
  value       = module.api_gateway.rest_api_invoke_url
  description = "API Gateway invoke URL"
}

output "api_gateway_base_url" {
  value       = module.api_gateway.localstack_base_url
  description = "Base URL for API Gateway in LocalStack"
}

output "api_gateway_payment_url" {
  value       = module.api_gateway.localstack_payment_url
  description = "Payment API URL via API Gateway"
}

output "api_gateway_payment_docs_url" {
  value       = module.api_gateway.localstack_payment_url != null ? "${module.api_gateway.localstack_payment_url}/api/docs" : null
  description = "Payment API Docs URL via API Gateway"
}

# SQS Queue URLs
output "create_payment_queue_url" {
  value = module.create-payment-queue.queue_url
}

output "payment_paid_queue_url" {
  value = module.payment-paid-queue.queue_url
}

output "mercado_pago_process_payment_queue_url" {
  value = module.mercado-pago-process-payment-queue.queue_url
}

output "cancel_payment_queue_url" {
  value = module.cancel-payment-queue.queue_url
}

