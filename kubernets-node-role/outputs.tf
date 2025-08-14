output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}
output "eks_node_role_name" {
  value = aws_iam_role.eks_node_role.name
}

output "eks_node_policy_attachments" {
  value = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy.id,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy.id,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly.id
  ]
}
