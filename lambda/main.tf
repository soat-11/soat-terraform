data "aws_caller_identity" "current" {
}
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project}-lambda-bucket"
}

resource "aws_s3_object" "upload_lambda" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "functions.zip"
  source = "${path.module}/functions.zip"
}

resource "aws_lambda_function" "signup" {
  function_name = "${var.project}-signup"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "functions/signup.handler"
  runtime       = "nodejs22.x"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.upload_lambda.key
}

resource "aws_lambda_function" "login" {
  function_name = "${var.project}-login"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "functions/login.handler"
  runtime       = "nodejs22.x"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.upload_lambda.key
}
