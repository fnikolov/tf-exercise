output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.public_alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.public_alb.dns_name
}

