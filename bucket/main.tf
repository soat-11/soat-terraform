resource "aws_s3_bucket" "backend_bucket" {
  bucket = "${var.project}-orders-eduardo" // trocar pelo seu bucket
  tags = {
    Name        = "${var.project}-orders"
    Environment = "Dev"
  }
}
