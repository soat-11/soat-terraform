output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
  description = "The ID of the REST API"
}

output "rest_api_invoke_url" {
  value = aws_api_gateway_stage.dev.invoke_url
  description = "The invoke URL of the REST API"
}
