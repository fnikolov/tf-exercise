# modules/s3_bucket/outputs.tf

#output "bucket_name" {
#  description = "The name of the S3 bucket"
#  value       = aws_s3_bucket.bucket.bucket
#}

#output "bucket_arn" {
#  description = "The ARN of the S3 bucket"
#  value       = aws_s3_bucket.bucket.arn
#}

#output "bucket_arn" {
#  description = "The ARN of the S3 bucket"
#  value       = aws_s3_bucket.marketing_static_files.arn
#}


# outputs.tf

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.marketing_static_files.arn
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.marketing_static_files.bucket
}

