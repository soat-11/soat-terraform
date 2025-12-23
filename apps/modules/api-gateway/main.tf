# ----------------------
# API Gateway
# ----------------------
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project}-api-gateway"
  description = "API Gateway para autenticação e EKS"
}

# ----------------------
# Lambda: Signup
# ----------------------
resource "aws_api_gateway_resource" "signup" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "signup"
}

resource "aws_api_gateway_method" "signup_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.signup.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "signup_post" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.signup_post.resource_id
  http_method = aws_api_gateway_method.signup_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.signup_lambda_arn
}

resource "aws_lambda_permission" "allow_api_gateway_signup" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.signup_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# ----------------------
# Lambda: Login
# ----------------------
resource "aws_api_gateway_resource" "login" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "login"
}

resource "aws_api_gateway_method" "login_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "login_post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_method.login_post.resource_id
  http_method             = aws_api_gateway_method.login_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.login_lambda_arn
}

resource "aws_lambda_permission" "allow_api_gateway_login" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.login_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
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
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = false
  }
}


resource "aws_api_gateway_resource" "payment" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "payment"
}


resource "aws_api_gateway_resource" "payment_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.payment.id
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_integration" "payment_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.payment_proxy.id
  http_method             = aws_api_gateway_method.payment_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.eks_nlb_hostname}/payment/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
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
  }
}


# ----------------------
# Deployment + Stage
# ----------------------
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.proxy_any,
    aws_api_gateway_integration.login_post,
    aws_api_gateway_integration.signup_post
  ]
}

resource "aws_api_gateway_stage" "stage_eks" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "prod"
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

