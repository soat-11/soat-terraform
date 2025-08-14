output "eks_role_arn" {
  value = aws_iam_role.cluster.arn
}

output "eks_policy_attachments" {
  value = aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy[*].id
}
