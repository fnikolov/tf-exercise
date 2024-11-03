terraform {
  backend "s3" {
    bucket = "tf-state-flutter-poc"
    key    = "tfstate"
    region = "us-east-1"
    profile = "default"
  }
}
# Provider Configuration
provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Public Subnets (one per AZ)
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Private Subnets (one per AZ)
resource "aws_subnet" "private" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 3)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group for ALB to allow HTTP traffic from the internet
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from all IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2 instances with S3 access
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

# IAM Policy for S3 access to the specific bucket
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
          aws_s3_bucket.marketing_static_files.arn,
          "${aws_s3_bucket.marketing_static_files.arn}/*"
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


resource "aws_iam_policy" "ec2_instance_connect_access" {
  name = "EC2InstanceConnectAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2-instance-connect:SendSSHPublicKey"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_instance_connect_access" {
  user       = var.user_or_role
  #role       = var.user_or_role
  policy_arn = aws_iam_policy.ec2_instance_connect_access.arn
}







# EC2 Instances with updated security groups
resource "aws_instance" "marketing" {
  count                   = var.instance_count
  ami                     = var.ami
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.private[count.index % length(aws_subnet.private)].id
  associate_public_ip_address = false
  iam_instance_profile    = aws_iam_instance_profile.ec2_instance_profile.name

  # Attach both SSH and port 80 access security groups
  vpc_security_group_ids  = [
    aws_security_group.ec2_ssh.id,
    aws_security_group.ec2_access.id
  ]

  root_block_device {
    volume_size = var.root_block_device["volume_size"]
    volume_type = var.root_block_device["volume_type"]
  }

  user_data = <<-EOL
  #!/bin/sh -xe
  sudo dnf install httpd -y
  sudo systemctl start httpd
  sudo systemctl enable httpd
  EOL




  tags = {
    Name = "marketing-${count.index + 1}"
  }
}









resource "aws_ec2_instance_connect_endpoint" "ec2_instance_connect" {
  subnet_id         = aws_subnet.private[0].id  # Attach to private subnets
  security_group_ids = [aws_security_group.ec2_instance_connect_sg.id]
}


resource "aws_security_group" "ec2_ssh" {
  name   = "ec2-ssh-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow SSH from EC2 Instance Connect Endpoint"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_instance_connect_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_access" {
  vpc_id = aws_vpc.main.id
  # Other security group rules (SSH, etc.)

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]  # Allows all internal VPC traffic
  }

  # Add egress rules if necessary
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"   # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "ec2_instance_connect_sg" {
  name   = "ec2-instance-connect-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS for EC2 Instance Connect"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTPS from all IPs for EC2 Instance Connect
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Call ALB Module for Public ALB
module "public_alb" {
  source            = "./modules/alb"
  name              = "marketing"
  vpc_id            = aws_vpc.main.id
  subnet_ids        = aws_subnet.public[*].id    # Use public subnets
  security_group_id = aws_security_group.alb_sg.id
  instance_ids      = aws_instance.marketing[*].id
}

# S3 Bucket for marketing static files (no ACL specified)
resource "aws_s3_bucket" "marketing_static_files" {
  bucket = "marketing-static-files-${var.region}-${random_string.suffix.result}"

  tags = {
    Name        = "marketing_static_files"
    Environment = "production"
  }
}

# Random suffix to ensure bucket name uniqueness
resource "random_string" "suffix" {
  length  = 12
  special = false
  upper   = false
}

# Data source to get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}














# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"  # Specifies the Elastic IP is within a VPC
}

# Define or use an existing Internet Gateway for the NAT Gateway
data "aws_internet_gateway" "existing_gw" {
  filter {
    name   = "attachment.vpc-id"
    values = [aws_vpc.main.id]
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  count = length(data.aws_internet_gateway.existing_gw.id) == 0 ? 1 : 0
}

locals {
  internet_gateway_id = length(data.aws_internet_gateway.existing_gw.id) > 0 ? data.aws_internet_gateway.existing_gw.id : aws_internet_gateway.gw[0].id
}

# NAT Gateway using the allocated Elastic IP
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.gw]  # Ensure the Internet Gateway exists
}

# Route table for private subnets with NAT Gateway as the route to the internet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Associate private route table with each private subnet
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
