locals {
  lambda_zip     = var.lambda_zip_path != "" ? var.lambda_zip_path : "${path.module}/lambda.zip"
  runtime        = var.is_local ? "nodejs18.x" : "nodejs22.x"
  handler_prefix = var.is_local ? "index" : "functions/signup"
}

# -----------------------------------------------------------------------------
# IAM Role for Lambda
# -----------------------------------------------------------------------------
# Cria um role próprio quando var.role_arn não é fornecido.
# Isso garante que o role tenha a trust policy correta para Lambda.
#
# Para usar um role externo (ex: LabRole do AWS Academy):
#   role_arn = "arn:aws:iam::123456789012:role/LabRole"
# -----------------------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  count = var.role_arn == "" ? 1 : 0

  name = "${var.project}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count      = var.role_arn == "" ? 1 : 0
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

locals {
  # Usa role externo se fornecido, senão usa o role criado acima
  effective_role_arn = var.role_arn != "" ? var.role_arn : aws_iam_role.lambda_role[0].arn
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project}-lambda-bucket-v2"

  tags = {
    Name        = "${var.project}-lambda"
    Environment = var.is_local ? "Local" : "Production"
  }
}

# Upload do ZIP para S3 (necessário para arquivos > 50MB)
resource "aws_s3_object" "lambda_zip" {
  count = var.is_local ? 0 : 1

  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda-code.zip"
  source = local.lambda_zip
  etag   = filemd5(local.lambda_zip)
}

resource "aws_lambda_function" "signup" {
  function_name = "${var.project}-signup"
  role          = local.effective_role_arn
  handler       = var.is_local ? "index.handler" : "functions/signup.handler"
  runtime       = local.runtime
  timeout       = 15

  # Upload direto para local, via S3 para produção (suporta arquivos grandes)
  filename         = var.is_local ? local.lambda_zip : null
  s3_bucket        = var.is_local ? null : aws_s3_bucket.lambda_bucket.id
  s3_key           = var.is_local ? null : aws_s3_object.lambda_zip[0].key
  source_code_hash = var.is_local ? null : filebase64sha256(local.lambda_zip)

  depends_on = [
    aws_s3_bucket.lambda_bucket,
    aws_iam_role_policy_attachment.lambda_basic
  ]
}

resource "aws_lambda_function" "login" {
  function_name = "${var.project}-login"
  role          = local.effective_role_arn
  handler       = var.is_local ? "index.handler" : "functions/login.handler"
  runtime       = local.runtime
  timeout       = 15

  # Upload direto para local, via S3 para produção (suporta arquivos grandes)
  filename         = var.is_local ? local.lambda_zip : null
  s3_bucket        = var.is_local ? null : aws_s3_bucket.lambda_bucket.id
  s3_key           = var.is_local ? null : aws_s3_object.lambda_zip[0].key
  source_code_hash = var.is_local ? null : filebase64sha256(local.lambda_zip)

  depends_on = [
    aws_s3_bucket.lambda_bucket,
    aws_iam_role_policy_attachment.lambda_basic
  ]
}

