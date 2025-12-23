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
<<<<<<< HEAD:kubernetes/modules/cluster/outputs.tf
}

=======

}
>>>>>>> b95176b590062352045630689a54a6cc75206f78:k8s/cluster/outputs.tf
