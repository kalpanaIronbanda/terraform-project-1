resource "aws_s3_bucket" "packagestore" {
  bucket = "artifact-storing-bucket-1"

  tags = {
    Name        = "artifact-storing-bucket"
    Environment = "Dev"
  }
}