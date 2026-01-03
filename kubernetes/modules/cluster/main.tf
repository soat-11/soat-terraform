# -----------------------------------------------------------------------------
# IAM Role for EKS Cluster
# -----------------------------------------------------------------------------
# Cria role próprio quando var.eks_role_arn não é fornecido.
# Para usar LabRole (AWS Academy), passe:
#   eks_role_arn = "arn:aws:iam::123456789012:role/LabRole"
# -----------------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster" {
  count = var.eks_role_arn == "" ? 1 : 0

  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.eks_role_arn == "" ? 1 : 0
  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

locals {
  cluster_role_arn = var.eks_role_arn != "" ? var.eks_role_arn : aws_iam_role.eks_cluster[0].arn
}

# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-eks-cluster"
  role_arn = local.cluster_role_arn

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
    security_group_ids      = var.security_group_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}
