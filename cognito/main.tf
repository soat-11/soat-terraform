resource "aws_cognito_user_pool" "aws_cognito_create_pool" {
  name = "soat-user-pool"

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ schema ]
  }

  auto_verified_attributes = ["email"]

  # Login será feito pelo CPF (armazenado em username)
  username_attributes = []

  schema {
    name                 = "name"
    attribute_data_type  = "String"
    required             = false
    mutable              = true
  }

  schema {
    name                 = "email"
    attribute_data_type  = "String"
    required             = true
    mutable              = true
  }
}

resource "aws_cognito_user_pool_client" "aws_cognito_create_app_client" {
  name         = "soat-app-client"
  user_pool_id = aws_cognito_user_pool.aws_cognito_create_pool.id
  generate_secret = false 

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
}

resource "aws_ssm_parameter" "user_pool_id" {
  name  = "/cognito/user_pool_id"
  type  = "String"
  value = aws_cognito_user_pool.aws_cognito_create_pool.id
}

resource "aws_ssm_parameter" "app_client_id" {
  name  = "/cognito/app_client_id"
  type  = "String"
  value = aws_cognito_user_pool_client.aws_cognito_create_app_client.id
}
