data "aws_caller_identity" "current" {
}

resource "aws_eks_access_entry" "access_entry" {
  cluster_name      = var.cluster_name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"
  kubernetes_groups = ["group-soat"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_access_policy" {
  cluster_name  = var.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"

  access_scope {
    type = "cluster"
  }
}
