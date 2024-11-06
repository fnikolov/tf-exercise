# modules/ec2_instance/outputs.tf

output "instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.marketing[*].id
}

output "public_ips" {
  description = "The public IP addresses of the EC2 instances"
  value       = aws_instance.marketing[*].public_ip
}

#output "ec2_instance_connect_sg_id" {
#  description = "The ID of the EC2 instance connect security group"
#  value       = aws_security_group.ec2_instance_connect_sg.id
#}

output "ec2_instance_sg_id" {
  description = "The ID of the EC2 instance security group"
  value       = aws_security_group.ec2_sg.id
}

#output "ec2_instance_sg_id" {
#  description = "The ID of the security group used by EC2 instances"
#  value       = aws_security_group.ec2_instance_sg.id
#}
