variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "ami" {
  description = "The ID of the AMI to use for the EC2 instance"
  type        = string
  default     = "ami-06b21ccaeff8cd686"
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}

variable "root_block_device" {
  description = "Configuration of the root block device, including size and type"
  type = map(any)
  default = {
    volume_size = 20    # Default volume size in GB
    volume_type = "gp2" # Default volume type
  }
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1  # Default number of instances
}

variable "user_or_role" {
  description = "IAM user or role to attach EC2 Instance Connect access policy"
  type        = string
}

