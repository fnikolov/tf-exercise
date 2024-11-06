output "instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.marketing[*].id
}

output "public_ips" {
  description = "The public IP addresses of the EC2 instances"
  value       = aws_instance.marketing[*].public_ip
}

output "ec2_instance_sg_id" {
  description = "The ID of the EC2 instance security group"
  value       = aws_security_group.ec2_sg.id
}

