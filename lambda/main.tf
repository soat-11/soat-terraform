data "aws_caller_identity" "current" {
}

data "archive_file" "zipit" {
  type        = "zip"
  source_dir = "${path.module}/src"
  output_path = "${path.module}/src/lambda.zip"
}

resource "aws_lambda_function" "auth" {
  function_name = "${var.project}-authorizer"
  role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "dist/index.handler"
  runtime       = "nodejs22.x"

  filename         = "${path.module}/src/lambda.zip"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
}
