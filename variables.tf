variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}

variable "instance_type_secondary" {
  description = "The type of EC2 instance to launch in the secondary region"
  type        = string
}

variable "root_block_device" {
  description = "Configuration of the root block device, including size and type"
  type = map(any)
  default = {
    volume_size = 20    # Default volume size in GB
    volume_type = "gp2" # Default volume type
  }
}

variable "root_block_device_secondary" {
  description = "Root block device configuration for EC2 instances in the secondary region"
  type = object({
    volume_size = number
    volume_type = string
  })
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1  # Default number of instances
}

variable "instance_count_secondary" {
  description = "The number of EC2 instances to launch in the secondary region"
  type        = number
}

variable "primary_region" {
  description = "Primary AWS region to deploy resources"
  type        = string
}

variable "secondary_region" {
  description = "Secondary AWS region to deploy resources"
  type        = string
}

variable "ami" {
  description = "AMI ID for the primary region"
  type        = string
}

variable "ami_secondary" {
  description = "The AMI ID to use for EC2 instances in the secondary region"
  type        = string
}

variable "primary_vpc_cidr" {
  description = "The CIDR block for the primary VPC"
  type        = string
}

variable "secondary_vpc_cidr" {
  description = "The CIDR block for the secondary VPC"
  type        = string
}

variable "project_name" {
  description = "The name of the project for tagging resources"
  type        = string
}

variable "environment" {
  description = "The environment for tagging resources (e.g., dev, prod)"
  type        = string
}

variable "primary_certificate_arn" {
  description = "The ARN of the ACM certificate to use for the ALB HTTPS listener"
  type        = string
}

variable "secondary_certificate_arn" {
  description = "The ARN of the ACM certificate to use for the ALB HTTPS listener"
  type        = string
}
