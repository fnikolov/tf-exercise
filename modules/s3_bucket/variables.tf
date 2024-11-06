variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
}

variable "vpce_id" {
  description = "VPC Endpoint ID for bucket policy"
  type        = string
}

variable "project_name" {
  description = "The name of the project for tagging resources"
  type        = string
}

variable "region" {
  description = "The AWS region for the S3 bucket"
  type        = string
}

