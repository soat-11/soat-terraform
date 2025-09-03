data "aws_caller_identity" "current" {}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }


  data = {
    mapRoles = jsonencode([
      {
        rolearn  = var.eks_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:masters"]
      },
    ])
    mapUsers = jsonencode([
      {
        userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        username = "root"
        groups   = ["system:masters"]
      },
    ])
  }

  lifecycle {
    ignore_changes = [metadata, data]
  }
}
