variable "name" {
  description = "Name prefix for the ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ALB and target group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB to use"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to attach to the ALB"
  type        = string
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to attach to the target group"
  type        = list(string)
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate to use for the ALB HTTPS listener"
  type        = string
}
