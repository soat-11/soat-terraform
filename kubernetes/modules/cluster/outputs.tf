output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "eks_service_role_arn" {
  value = aws_eks_cluster.eks_cluster.role_arn
}

# OIDC outputs for IRSA
output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA (without https://)"
  value       = replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
}
