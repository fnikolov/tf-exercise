# modules/s3_bucket/main.tf

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${random_string.suffix.result}"
  #  acl    = "private"

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

# Random suffix to ensure bucket name uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper = false
}

# Optionally, add a bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowAccessFromVPCEndpoint",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/*",
        Condition = {
          StringEquals = {
            "aws:SourceVpce": var.vpce_id
          }
        }
      }
    ]
  })
}

