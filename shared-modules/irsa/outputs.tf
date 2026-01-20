output "role_arn" {
  description = "ARN of the IAM role for the service"
  value       = aws_iam_role.service_role.arn
}

output "role_name" {
  description = "Name of the IAM role for the service"
  value       = aws_iam_role.service_role.name
}

output "service_account_name" {
  description = "Name of the Kubernetes service account"
  value       = kubernetes_service_account.sa.metadata[0].name
}
