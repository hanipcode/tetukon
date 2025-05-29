output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "traefik_target_group_arn" {
  description = "ARN of the Traefik target group"
  value       = aws_lb_target_group.traefik.arn
}

output "alb_logs_cloudwatch_group" {
  description = "CloudWatch log group for ALB logs"
  value       = aws_cloudwatch_log_group.alb_logs.name
} 