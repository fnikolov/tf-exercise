# main.tf

terraform {
  backend "s3" {
    bucket  = "tf-state-flutter-poc"
    key     = "tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}

provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}


module "network_primary" {
  source = "./modules/network"
  providers = {
    aws = aws
  }

  vpc_cidr           = var.primary_vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  project_name       = var.project_name
  environment        = var.environment
}

module "network_secondary" {
  source = "./modules/network"
  providers = {
    aws = aws.secondary
  }

  vpc_cidr           = var.secondary_vpc_cidr
  availability_zones = data.aws_availability_zones.secondary.names
  project_name       = var.project_name
  environment        = var.environment
}



#module "network_primary" {
#  source             = "./modules/network"
#  providers = {
#    aws = aws  # Primary region provider
#  }
#  vpc_cidr           = "10.0.0.0/16"
#  project_name       = "flutter-poc"
#  availability_zones = data.aws_availability_zones.available.names
#}

#module "network_secondary" {
#  source             = "./modules/network"
#  providers = {
#    aws = aws.secondary  # Secondary region provider
#  }
#  vpc_cidr           = "10.1.0.0/16"
#  project_name       = "flutter-poc-eu"
#  availability_zones = data.aws_availability_zones.available_secondary.names
#}

# Data source to get availability zones for the primary region
data "aws_availability_zones" "available" {
  provider = aws
  state    = "available"
}

# Data source to get availability zones for the secondary region
data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state    = "available"
}


module "ec2_primary" {
  source = "./modules/ec2_instance"
  providers = {
    aws = aws
  }

  vpc_id             = module.network_primary.vpc_id  # Use the output from the network module
  subnet_ids         = module.network_primary.private_subnet_ids
  instance_count     = var.instance_count
  ami                = var.ami
  instance_type      = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  root_block_device  = {
    volume_size = var.root_block_device["volume_size"]
    volume_type = var.root_block_device["volume_type"]
  }
  project_name       = var.project_name
  security_group_id  = module.network_primary.public_subnet_ids[0]  # Example security group reference
}

module "ec2_secondary" {
  source = "./modules/ec2_instance"
  providers = {
    aws = aws.secondary  # Use the secondary region provider
  }

  vpc_id             = module.network_secondary.vpc_id  # Use the output from the network_secondary module
  subnet_ids         = module.network_secondary.private_subnet_ids
  instance_count     = var.instance_count_secondary
  ami                = var.ami_secondary
  instance_type      = var.instance_type_secondary
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile_secondary.name
  root_block_device  = {
    volume_size = var.root_block_device_secondary["volume_size"]
    volume_type = var.root_block_device_secondary["volume_type"]
  }
  project_name       = var.project_name
  security_group_id  = module.network_secondary.public_subnet_ids[0]  # Security group reference for secondary network
}







module "alb_primary" {
  source = "./modules/alb"
  providers = {
    aws = aws  # Primary region provider
  }
  vpc_id       = module.network_primary.vpc_id
  name         = "flutter-poc-primary"
  subnet_ids   = module.network_primary.public_subnet_ids
  certificate_arn   = var.certificate_arn
  security_group_id = module.alb_primary.alb_sg_id
  instance_ids      = module.ec2_primary.instance_ids
}

#IAM
# Define an IAM Role for EC2 instances
resource "aws_iam_role" "ec2_s3_access" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

# IAM Policy for S3 access (if needed)
resource "aws_iam_policy" "s3_access_policy" {
  name = "s3_access_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          module.s3_primary.bucket_arn,
          "${module.s3_primary.bucket_arn}/*"
        ]
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attach" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# IAM Instance Profile for EC2 to use the IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_s3_access.name
}



##### S3
# Use the S3 bucket module in the primary region
module "s3_primary" {
  source      = "./modules/s3_bucket"
  providers = {
    aws = aws  # Primary region provider
  }
  bucket_name = "marketing-static-files"
  environment = "production"
  vpce_id     = aws_vpc_endpoint.s3.id
}

# Use the S3 bucket module in the secondary region
module "s3_secondary" {
  source      = "./modules/s3_bucket"
  providers = {
    aws = aws.secondary  # Secondary region provider
  }
  bucket_name = "marketing-static-files-eu"
  environment = "production"
  vpce_id     = aws_vpc_endpoint.s3_secondary.id
}

#######################
# VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.network_primary.vpc_id  # Ensure this uses the correct VPC from the network module
  service_name      = "com.amazonaws.${var.primary_region}.s3"
  vpc_endpoint_type = "Gateway"  # Change to "Gateway" for S3 endpoint
  route_table_ids = [
    module.network_primary.public_route_table_id,
    module.network_primary.private_route_table_id
  ]

  tags = {
    Name = "s3-vpc-endpoint-${var.primary_region}"
  }
}

# VPC Endpoint for S3 in Secondary Region
resource "aws_vpc_endpoint" "s3_secondary" {
  vpc_id            = module.network_secondary.vpc_id
  service_name      = "com.amazonaws.${var.secondary_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    module.network_secondary.public_route_table_id,
    module.network_secondary.private_route_table_id
  ]

  provider = aws.secondary  # Secondary region provider


  tags = {
    Name = "s3-vpc-endpoint-${var.secondary_region}"
  }
}

