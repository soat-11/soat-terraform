output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_ca" {
  description = "The certificate authority data for the EKS cluster"
  value       = module.eks_cluster.cluster_ca
  sensitive   = true
}

# OIDC outputs for IRSA
output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = module.eks_cluster.oidc_provider_arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA (without https://)"
  value       = module.eks_cluster.oidc_issuer_url
}

