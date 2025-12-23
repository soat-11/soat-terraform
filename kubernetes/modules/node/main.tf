resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project}-node-group"
  node_role_arn   = var.eks_role_arn

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
}

