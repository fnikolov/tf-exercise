# modules/network/variables.tf

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "project_name" {
  description = "Project name for resource tags"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "environment" {
  description = "The environment for tagging resources (e.g., dev, prod)"
  type        = string
}
