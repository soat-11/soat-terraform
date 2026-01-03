# -----------------------------------------------------------------------------
# IAM Role for EKS Node Group
# -----------------------------------------------------------------------------
# Cria role próprio quando var.eks_role_arn não é fornecido.
# Para usar LabRole (AWS Academy), passe:
#   eks_role_arn = "arn:aws:iam::123456789012:role/LabRole"
# -----------------------------------------------------------------------------
resource "aws_iam_role" "eks_node" {
  count = var.eks_role_arn == "" ? 1 : 0

  name = "${var.project}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Policies necessárias para EKS Node Group
resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  count      = var.eks_role_arn == "" ? 1 : 0
  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  count      = var.eks_role_arn == "" ? 1 : 0
  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  count      = var.eks_role_arn == "" ? 1 : 0
  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

locals {
  node_role_arn = var.eks_role_arn != "" ? var.eks_role_arn : aws_iam_role.eks_node[0].arn
}

# -----------------------------------------------------------------------------
# EKS Node Group
# -----------------------------------------------------------------------------
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project}-node-group"
  node_role_arn   = local.node_role_arn

  subnet_ids = var.subnet_ids

  # SPOT INSTANCE - economia de ate 70-80%
  capacity_type  = "SPOT"
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.project}-node"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.ecr_read
  ]
}
