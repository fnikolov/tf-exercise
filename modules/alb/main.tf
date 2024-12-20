# Application Load Balancer
resource "aws_lb" "public_alb" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids

  tags = {
    Name = "${var.name}-public-alb"
  }
}

# Security Group for ALB to allow HTTP/HTTPS traffic from the internet
resource "aws_security_group" "alb_sg" {
  name   = "${var.name}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from all IPs
  }

  ingress {
    description = "Allow HTTPS from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from all IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

# HTTP Listener (Port 80) - Redirects to HTTPS
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener (Port 443) - Forwards to Target Group
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.public_alb.arn  # Use public_alb here
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  #certificate_arn   = "arn:aws:acm:us-east-1:605134433422:certificate/31669afb-304a-4ed7-a5dd-5243a83181a2" #var.certificate_arn           # Provide an ACM Certificate ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_target_group.arn
  }
}

# Target Group
resource "aws_lb_target_group" "ec2_target_group" {
  name     = "${var.name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "ec2_attachment" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.ec2_target_group.arn
  target_id        = var.instance_ids[count.index]
  port             = 80
}

