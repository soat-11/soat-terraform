resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project}-api-gateway"
  description = "API Gateway para autenticação e EKS"
}

# # Root Resource
# data "aws_api_gateway_resource" "root" {
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   path        = "/"
# }

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
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_method.signup_post.resource_id
  http_method             = aws_api_gateway_method.signup_post.http_method
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
  parent_id   = data.aws_api_gateway_resource.root.id
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
  resource_id             = aws_api_gateway_resource.login.id
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

resource "aws_api_gateway_deployment" "gateway_deployment" {
  depends_on = [
    aws_api_gateway_integration.login_post,
    aws_api_gateway_integration.signup_post
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id
}

# ----------------------
# Proxy para EKS
# ----------------------
data "aws_lb" "eks_lb_api" {}

data "aws_vpcs" "selected" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_vpc" "eks_vpc" {
  id = data.aws_vpcs.selected.ids[0]
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.selected.ids[0]]
  }
}

data "aws_subnet" "selected" {
  for_each = toset(data.aws_subnets.selected.ids)

  id = each.value
}

resource "aws_api_gateway_vpc_link" "eks" {
  name        = "eks-gateway-vpclink"
  description = "Eks Gateway VPC Link. Managed by Terraform."
  target_arns = [data.aws_lb.eks_lb_api.arn]
}
resource "aws_api_gateway_rest_api" "main" {
  name        = "eks-gateway"
  description = "Gateway used for EKS. Managed by Terraform."
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_any" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks.id
  uri                     = "http://${data.aws_lb.eks_lb_api.dns_name}:3010/{proxy}"
    passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Accept"        = "'application/json'"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

# ----------------------
# Deployment + Stage
# ----------------------
resource "aws_api_gateway_deployment" "deployment_eks" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ 
    aws_api_gateway_integration.proxy_any,
    aws_api_gateway_rest_api.main,
    aws_api_gateway_method.proxy_any
    ]
}

resource "aws_api_gateway_stage" "stage_eks" {
  deployment_id = aws_api_gateway_deployment.deployment_eks.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "dev"
}

resource "aws_api_gateway_method_settings" "settings-eks" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.stage_eks.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
  }
}
