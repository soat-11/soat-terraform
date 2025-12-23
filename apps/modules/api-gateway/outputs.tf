output "rest_api_invoke_url" {
  value       = aws_api_gateway_stage.stage_eks.invoke_url
  description = "The invoke URL of the REST API"
}

output "rest_api_id" {
  value       = aws_api_gateway_rest_api.this.id
  description = "The ID of the REST API"
}

output "localstack_base_url" {
  value       = var.is_local ? "http://localhost:4566/restapis/${aws_api_gateway_rest_api.this.id}/prod/_user_request_" : null
  description = "Base URL for API Gateway in LocalStack (only when is_local=true)"
}

output "localstack_payment_url" {
  value       = var.is_local ? "http://localhost:4566/restapis/${aws_api_gateway_rest_api.this.id}/prod/_user_request_/payment" : null
  description = "Payment API URL via LocalStack API Gateway"
}

