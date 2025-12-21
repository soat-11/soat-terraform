output "rest_api_invoke_url" {
  value       = aws_api_gateway_stage.stage_eks.invoke_url
  description = "The invoke URL of the REST API"
}

