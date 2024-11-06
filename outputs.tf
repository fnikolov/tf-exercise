
output "s3_vpce_id_primary" {
  description = "The ID of the VPC Endpoint for S3 in the primary region"
  value       = aws_vpc_endpoint.s3.id
}

output "s3_vpce_id_secondary" {
  description = "The ID of the VPC Endpoint for S3 in the secondary region"
  value       = aws_vpc_endpoint.s3_secondary.id
}

#output "ec2_instance_profile_arn" {
#  description = "The ARN of the EC2 instance profile"
#  value       = aws_iam_instance_profile.ec2_instance_profile.arn
#}

output "ec2_instance_profile_name" {
  description = "The name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

