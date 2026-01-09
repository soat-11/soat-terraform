resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project}-lambda"

    tags = {
      Name = "${var.project}-lambda"
  }
}

resource "aws_lambda_function" "signup_and_login" {
  function_name = "${var.project}-signup-and-login"
  role          = var.role_arn
  handler       = "functions/signup-and-login.handler"
  runtime       = "nodejs22.x"
  timeout = 15

  filename         = "lambda.zip" 
  source_code_hash = filebase64sha256("lambda.zip")
  # s3_bucket = aws_s3_bucket.lambda_bucket.id
  # s3_key    = "lambda.zip"

  depends_on = [aws_s3_bucket.lambda_bucket]
}

resource "aws_lambda_function" "anonymous_login" {
  function_name = "${var.project}-anonymous-login"
  role          = var.role_arn
  handler       = "functions/anonymous-login.handler"
  runtime       = "nodejs22.x"
  timeout = 15

  filename         = "lambda.zip" 
  source_code_hash = filebase64sha256("lambda.zip")
  # s3_bucket = aws_s3_bucket.lambda_bucket.id
  # s3_key    = "lambda.zip"

  depends_on = [aws_s3_bucket.lambda_bucket]
}
