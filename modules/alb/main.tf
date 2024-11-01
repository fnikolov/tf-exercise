resource "aws_lb" "public_alb" {
  name               = "${var.name}-alb"
  internal           = false               # Set to false to make it internet-facing
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids      # These should be public subnets

  tags = {
    Name = "${var.name}-public-alb"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.public_alb.arn  # Use public_alb here
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_target_group.arn
  }
}

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

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.ec2_target_group.arn
  target_id        = var.instance_ids[count.index]
  port             = 80
}

