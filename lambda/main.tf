data "aws_caller_identity" "current" {
}

data "archive_file" "zipit" {
  type        = "zip"
  source_file = "${path.module}/js/index.mjs"
  output_path = "${path.module}/js/lambda-auth-cpf.zip"
}

resource "aws_lambda_function" "auth" {
  function_name = "${var.project}-auth-lambda"
  role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "dist/index.handler"
  runtime       = "nodejs22.x"

  filename         = var.lambda_package
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
}
