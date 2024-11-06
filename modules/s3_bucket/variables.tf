# modules/s3_bucket/variables.tf

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
}

variable "vpce_id" {
  description = "VPC Endpoint ID for bucket policy"
  type        = string
}

