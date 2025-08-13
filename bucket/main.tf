resource "aws_s3_bucket" "backend_bucket" {
  bucket = "${var.project}-state"

  tags = {
    Name        = "${var.project}-state"
    Environment = "Dev"
  }
}
