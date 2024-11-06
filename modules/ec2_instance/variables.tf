# modules/ec2_instance/variables.tf

variable "instance_count" {
  description = "Number of EC2 instances to launch"
  type        = number
}

variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where instances will be created"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the EC2 instances"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to the EC2 instances"
  type        = string
}

variable "root_block_device" {
  description = "Configuration for the root block device"
  type        = map(string)
}

variable "project_name" {
  description = "Project name to use in resource tags"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instances and security groups will be created"
  type        = string
}

