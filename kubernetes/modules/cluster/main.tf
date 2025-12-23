data "aws_caller_identity" "current" {}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-eks-cluster"
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false

    security_group_ids = var.security_group_ids
  }
<<<<<<< HEAD:kubernetes/modules/cluster/main.tf
}

=======
}
>>>>>>> b95176b590062352045630689a54a6cc75206f78:k8s/cluster/main.tf
