# -----------------------------------------------------------------------------
# IRSA (IAM Roles for Service Accounts) Module
# -----------------------------------------------------------------------------
# Creates:
# - IAM Role with trust policy for OIDC
# - IAM Policy with SQS permissions (producer/consumer)
# - IAM Policy for Secrets Manager access
# - Kubernetes Service Account annotated with IAM role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "service_role" {
  name = "${var.service_name}-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_issuer_url}:sub" = "system:serviceaccount:${var.namespace}:${var.service_name}-sa"
          "${var.oidc_issuer_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.service_name}-irsa-role"
    Application = var.service_name
  }
}

# SQS Policy - Producer permissions
resource "aws_iam_role_policy" "sqs_producer_policy" {
  count = length(var.producer_queue_arns) > 0 ? 1 : 0

  name = "${var.service_name}-sqs-producer-policy"
  role = aws_iam_role.service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ]
      Resource = var.producer_queue_arns
    }]
  })
}

# SQS Policy - Consumer permissions
resource "aws_iam_role_policy" "sqs_consumer_policy" {
  count = length(var.consumer_queue_arns) > 0 ? 1 : 0

  name = "${var.service_name}-sqs-consumer-policy"
  role = aws_iam_role.service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ChangeMessageVisibility"
      ]
      Resource = var.consumer_queue_arns
    }]
  })
}

# Secrets Manager Policy
resource "aws_iam_role_policy" "secrets_policy" {
  count = length(var.secrets_arns) > 0 ? 1 : 0

  name = "${var.service_name}-secrets-policy"
  role = aws_iam_role.service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.secrets_arns
    }]
  })
}

# Kubernetes Service Account with IRSA annotation
resource "kubernetes_service_account" "sa" {
  metadata {
    name      = "${var.service_name}-sa"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.service_role.arn
    }
  }
}
