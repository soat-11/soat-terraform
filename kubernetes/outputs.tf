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

