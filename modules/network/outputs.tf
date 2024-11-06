# Output for Public Subnet IDs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

# Output for Private Subnet IDs
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# Output for VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# Output for Public Route Table ID
output "public_route_table_id" {
  value = aws_route_table.public.id
}

# Output for Private Route Table ID
output "private_route_table_id" {
  value = aws_route_table.private.id
}

