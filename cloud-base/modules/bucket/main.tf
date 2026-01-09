resource "aws_s3_bucket" "backend_bucket" {
  bucket = "${var.project}-orders-v2"
  tags = {
    Name        = "${var.project}-orders"
    Environment = var.is_local ? "Local" : "Production"
  }
}

