output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "service_names" {
  description = "Names of the ECS services"
  value       = { for k, v in aws_ecs_service.services : k => v.name }
}

output "service_arns" {
  description = "Map of service names to ECS service ARNs"
  value       = { for k, v in aws_ecs_service.services : k => v.id }
}

output "task_definition_arns" {
  description = "Map of service names to task definition ARNs"
  value       = { for k, v in aws_ecs_task_definition.services : k => v.arn }
}

output "log_group_names" {
  description = "CloudWatch log group names"
  value       = { for k, v in aws_cloudwatch_log_group.services : k => v.name }
}

output "services_security_group_id" {
  description = "ID of the services security group"
  value       = aws_security_group.services.id
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "traefik_service_name" {
  description = "Name of the Traefik ECS service"
  value       = aws_ecs_service.traefik.name
}

output "service_discovery_namespace_id" {
  description = "ID of the service discovery namespace"
  value       = aws_service_discovery_private_dns_namespace.main.id
}

output "service_discovery_services" {
  description = "Service discovery service ARNs"
  value       = { for k, v in aws_service_discovery_service.services : k => v.arn }
} 