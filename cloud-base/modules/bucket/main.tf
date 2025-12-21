resource "aws_s3_bucket" "backend_bucket" {
  bucket = "${var.project}-orders"
  tags = {
    Name        = "${var.project}-orders"
    Environment = "Dev"
  }
}

