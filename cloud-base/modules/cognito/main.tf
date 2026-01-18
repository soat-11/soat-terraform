# ----------------------
# Real Cognito (Production only)
# ----------------------
resource "aws_cognito_user_pool" "aws_cognito_create_pool" {
  count = var.is_local ? 0 : 1
  name  = "${var.project}-user-pool"

  lifecycle {
    create_before_destroy = true
  }


  username_attributes = []

  # auto_verified_attributes = []

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }
}

resource "aws_cognito_user_pool_client" "aws_cognito_create_app_client" {
  count           = var.is_local ? 0 : 1
  name            = "${var.project}-app-client"
  user_pool_id    = aws_cognito_user_pool.aws_cognito_create_pool[0].id
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}

# ----------------------
# SSM Parameters (stores real or mock values)
# ----------------------
resource "aws_ssm_parameter" "user_pool_id" {
  name      = "/cognito/user_pool_id"
  type      = "String"
  value     = var.is_local ? "local-user-pool-id-mock" : aws_cognito_user_pool.aws_cognito_create_pool[0].id
  overwrite = true
}

resource "aws_ssm_parameter" "app_client_id" {
  name      = "/cognito/app_client_id"
  type      = "String"
  value     = var.is_local ? "local-app-client-id-mock" : aws_cognito_user_pool_client.aws_cognito_create_app_client[0].id
  overwrite = true
}

