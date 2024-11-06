resource "aws_s3_bucket" "marketing_static_files" {
  bucket = var.bucket_name  # Use bucket_name from variable

  tags = {
    Name        = "${var.project_name}-static-files"
    Environment = var.environment
  }
}

# Random suffix to ensure bucket name uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper = false
}

# Bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  #bucket = aws_s3_bucket.bucket.id
  bucket = aws_s3_bucket.marketing_static_files.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowAccessFromVPCEndpoint",
        Effect    = "Allow",
        Principal = "*",
        Action    = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource  = [
          aws_s3_bucket.marketing_static_files.arn,
          "${aws_s3_bucket.marketing_static_files.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceVpce": var.vpce_id
          }
        }
      }
    ]
  })
}

