# ----------------------
# API Gateway
# ----------------------
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project}-api-gateway"
  description = var.is_local ? "API Gateway for local testing" : "API Gateway para autenticação e EKS"
}

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name          = "CognitoAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.this.id
  provider_arns = [var.cognito_user_pool_arn]
}

# ----------------------
# Lambda: anonymous-login
# ----------------------
resource "aws_api_gateway_resource" "anonymous_login" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "anonymous-login"
}

resource "aws_api_gateway_method" "anonymous_login_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.anonymous_login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "anonymous_login_post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_method.anonymous_login_post.resource_id
  http_method             = aws_api_gateway_method.anonymous_login_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.anonymous_login_lambda_arn
}

resource "aws_lambda_permission" "allow_api_gateway_anonymous_login" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.anonymous_login_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}

# ----------------------
# Lambda: signup-and-login
# ----------------------
resource "aws_api_gateway_resource" "signup_and_login" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "signup-and-login"
}

resource "aws_api_gateway_method" "signup_and_login_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.signup_and_login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "signup_and_login_post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_method.signup_and_login_post.resource_id
  http_method             = aws_api_gateway_method.signup_and_login_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.signup_and_login_lambda_arn
}

resource "aws_lambda_permission" "allow_api_gateway_signup_and_login" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.signup_and_login_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}

# ----------------------
# Payment routes
# ----------------------
resource "aws_api_gateway_resource" "payment" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "payment"
}

resource "aws_api_gateway_method" "payment_root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.payment.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.header.x-session-id"  = false
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "payment_root" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.payment.id
  http_method             = aws_api_gateway_method.payment_root.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/payment"

  request_parameters = {
    "integration.request.header.x-session-id"  = "context.authorizer.claims.sub"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

resource "aws_api_gateway_resource" "payment_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.payment.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "payment_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.payment_proxy.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "payment_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.payment_proxy.id
  http_method             = aws_api_gateway_method.payment_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/payment/{proxy}"

 request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.header.x-session-id"  = "context.authorizer.claims.sub"
  }
}

# # ----------------------
# # Cart routes
# # ----------------------
resource "aws_api_gateway_resource" "cart" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "cart"
}

resource "aws_api_gateway_method" "cart_root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.cart.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.header.x-session-id"  = false
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "cart_root" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.cart.id
  http_method             = aws_api_gateway_method.cart_root.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/cart"

  request_parameters = {
    "integration.request.header.x-session-id"  = "context.authorizer.claims.sub"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

resource "aws_api_gateway_resource" "cart_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.cart.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "cart_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.cart_proxy.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "cart_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.cart_proxy.id
  http_method             = aws_api_gateway_method.cart_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/cart/{proxy}"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.header.x-session-id"  = "context.authorizer.claims.sub"
  }
}

# # ----------------------
# # Production routes
# # ----------------------
resource "aws_api_gateway_resource" "production" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "production"
}

resource "aws_api_gateway_method" "production_root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.production.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.header.x-session-id"  = false
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "production_root" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.production.id
  http_method             = aws_api_gateway_method.production_root.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/production"

  request_parameters = {
    "integration.request.header.x-session-id"  = "context.authorizer.claims.sub"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

resource "aws_api_gateway_resource" "production_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.production.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "production_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.production_proxy.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "production_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.production_proxy.id
  http_method             = aws_api_gateway_method.production_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/production/{proxy}"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.header.x-session-id"  = "context.authorizer.claims.sub"
  }
}

# # ----------------------
# # Order routes
# # ----------------------
resource "aws_api_gateway_resource" "order" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "order"
}

resource "aws_api_gateway_method" "order_root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.order.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.header.x-session-id"  = false
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "order_root" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.order.id
  http_method             = aws_api_gateway_method.order_root.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/order"

  request_parameters = {
    "integration.request.header.x-session-id"  = "context.authorizer.claims.sub"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

resource "aws_api_gateway_resource" "order_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.order.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "order_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.order_proxy.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "order_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.order_proxy.id
  http_method             = aws_api_gateway_method.order_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/order/{proxy}"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.header.x-session-id"  = "context.authorizer.claims.sub"
  }
}

# ----------------------
# Proxy para EKS - qualquer rota
# ----------------------
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "ANY"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "proxy_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.header.x-session-id"  = "context.authorizer.claims.sub"
  }
}

# ----------------------
# Deployment + Stage
# ----------------------
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      # Lambda routes
      aws_api_gateway_resource.anonymous_login.id,
      aws_api_gateway_resource.signup_and_login.id,
      aws_api_gateway_method.anonymous_login_post.id,
      aws_api_gateway_method.signup_and_login_post.id,
      aws_api_gateway_integration.anonymous_login_post.id,
      aws_api_gateway_integration.signup_and_login_post.id,
      # Payment routes
      aws_api_gateway_resource.payment.id,
      aws_api_gateway_resource.payment_proxy.id,
      aws_api_gateway_method.payment_root.id,
      aws_api_gateway_method.payment_any.id,
      aws_api_gateway_integration.payment_root.id,
      aws_api_gateway_integration.payment_any.id,
      # # Cart routes
      aws_api_gateway_resource.cart.id,
      aws_api_gateway_resource.cart_proxy.id,
      aws_api_gateway_method.cart_root.id,
      aws_api_gateway_method.cart_any.id,
      aws_api_gateway_integration.cart_root.id,
      aws_api_gateway_integration.cart_any.id,
      # # Production routes
      aws_api_gateway_resource.production.id,
      aws_api_gateway_resource.production_proxy.id,
      aws_api_gateway_method.production_root.id,
      aws_api_gateway_method.production_any.id,
      aws_api_gateway_integration.production_root.id,
      aws_api_gateway_integration.production_any.id,
      # # Order routes
      aws_api_gateway_resource.order.id,
      aws_api_gateway_resource.order_proxy.id,
      aws_api_gateway_method.order_root.id,
      aws_api_gateway_method.order_any.id,
      aws_api_gateway_integration.order_root.id,
      aws_api_gateway_integration.order_any.id,
      # Proxy route
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy_any.id,
      aws_api_gateway_integration.proxy_any.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.anonymous_login_post,
    aws_api_gateway_integration.signup_and_login_post,
    aws_api_gateway_integration.payment_root,
    aws_api_gateway_integration.payment_any,
    aws_api_gateway_integration.cart_root,
    aws_api_gateway_integration.cart_any,
    aws_api_gateway_integration.production_root,
    aws_api_gateway_integration.production_any,
    aws_api_gateway_integration.order_root,
    aws_api_gateway_integration.order_any,
    aws_api_gateway_integration.proxy_any
  ]
}

resource "aws_api_gateway_stage" "stage_eks" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.is_local ? "prod" : "development"
}

# ----------------------
# Method settings (opcional)
# ----------------------
resource "aws_api_gateway_method_settings" "settings-eks" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.stage_eks.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
  }
}
