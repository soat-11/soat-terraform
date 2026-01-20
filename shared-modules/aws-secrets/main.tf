# -----------------------------------------------------------------------------
# AWS Secrets Manager Module
# -----------------------------------------------------------------------------
# Creates:
# - AWS Secrets Manager secret
# - Secret version with the provided data
# -----------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "secret" {
  name                    = "${var.app_name}-secrets"
  description             = "Secrets for ${var.app_name} application"
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    {
      Name        = "${var.app_name}-secrets"
      Application = var.app_name
    },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(var.secret_data)
}
