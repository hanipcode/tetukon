output "traefik_security_group_id" {
  description = "ID of the Traefik security group"
  value       = aws_security_group.traefik.id
}

output "services_security_group_id" {
  description = "ID of the services security group"
  value       = aws_security_group.services.id
} 