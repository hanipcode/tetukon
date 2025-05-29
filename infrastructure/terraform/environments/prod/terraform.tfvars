aws_region   = "ap-southeast-1"
environment  = "prod"
project_name = "microservice-ecommerce"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
public_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
private_subnet_cidrs = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]

# Service Configuration
service_names = ["user-service", "store-service", "order-service"]
service_ports = {
  "user-service"  = 3001
  "store-service" = 3002
  "order-service" = 3003
}

# ECS Configuration - Higher resources for production
ecs_task_cpu      = 512
ecs_task_memory   = 1024
ecs_desired_count = 3  # Higher for production
ecs_min_capacity  = 2
ecs_max_capacity  = 20 # Higher for production

# SSL Configuration for production
enable_https = true
ssl_certificate_arn = ""  # Add your SSL certificate ARN here
domain_name = ""          # Add your domain name here 