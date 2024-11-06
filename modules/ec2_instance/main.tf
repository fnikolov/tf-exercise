# Security Group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name   = "${var.project_name}-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Update to restrict SSH access as needed
  }

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Update based on your requirements
  }

  ingress {
    description = "Allow HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Update based on your requirements
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# EC2 Instances (reference the security group)
resource "aws_instance" "marketing" {
  count                   = var.instance_count
  ami                     = var.ami
  instance_type           = var.instance_type
  subnet_id               = element(var.subnet_ids, count.index % length(var.subnet_ids))
  associate_public_ip_address = false
  iam_instance_profile    = var.iam_instance_profile
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id]



  root_block_device {
    volume_size = var.root_block_device["volume_size"]
    volume_type = var.root_block_device["volume_type"]
  }

  user_data = <<-EOL
  #!/bin/sh -xe
  sudo dnf install httpd -y
  sudo systemctl start httpd
  sudo systemctl enable httpd
  sudo echo "<html><body><h1>Welcome!</h1></body></html>" > /var/www/html/index.html
  EOL

  tags = {
    Name = "${var.project_name}-instance-${count.index + 1}"
  }
}

resource "aws_ec2_instance_connect_endpoint" "ec2_instance_connect" {
  subnet_id          = element(var.subnet_ids, 0)  # Use the first private subnet from the variable subnet_ids
  security_group_ids = [aws_security_group.ec2_sg.id]  # Reference the security group defined in this module

  tags = {
    Name = "${var.project_name}-ec2ic-vpc-endpoint"
  }
}













