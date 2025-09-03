resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project}-node-group"
  node_role_arn   = var.eks_role_arn

  subnet_ids     = var.subnet_ids
  instance_types = var.instance_types


  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.project}-node"

  }
}
