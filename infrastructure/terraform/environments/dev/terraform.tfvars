aws_region   = "us-west-2"
environment  = "dev"
project_name = "microservice-ecommerce"

# VPC Configuration
vpc_cidr = "10.192.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs  = ["10.192.10.0/24", "10.192.11.0/24"]
private_subnet_cidrs = ["10.192.20.0/24", "10.192.21.0/24"]

# Service Configuration
service_names = ["user-service", "store-service", "order-service"]
service_ports = {
  "user-service"  = 3001
  "store-service" = 3002
  "order-service" = 3003
}

# ECS Configuration
ecs_task_cpu      = 256
ecs_task_memory   = 512
ecs_desired_count = 1  # Lower for dev environment
ecs_min_capacity  = 1
ecs_max_capacity  = 5  # Lower for dev environment

# SSL Configuration (optional for dev)
enable_https = false
ssl_certificate_arn = ""
domain_name = "" 