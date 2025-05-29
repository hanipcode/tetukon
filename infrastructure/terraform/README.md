# Terraform Infrastructure for Microservice E-Commerce

This directory contains Terraform configurations for deploying the microservice e-commerce platform on AWS using Infrastructure as Code (IaC).

## 🏗️ Architecture Overview

The Terraform configuration creates:

- **VPC** with public/private subnets across multiple AZs
- **ECR repositories** for container images
- **Application Load Balancer** for traffic routing
- **ECS Fargate cluster** for container orchestration
- **Auto Scaling** policies for horizontal scaling
- **CloudWatch** logs for monitoring
- **IAM roles** with least privilege access

## 📁 Directory Structure

```
infrastructure/terraform/
├── main.tf                     # Root module orchestration
├── variables.tf               # Input variables
├── outputs.tf                # Output values
├── backend.tf                # State backend configuration
├── modules/                  # Reusable infrastructure modules
│   ├── vpc/                 # VPC and networking
│   ├── ecr/                 # Container registry
│   ├── alb/                 # Application Load Balancer
│   └── ecs/                 # Container orchestration
└── environments/            # Environment-specific configurations
    └── dev/
        └── terraform.tfvars # Development environment variables
```

## 🚀 Quick Start

### Prerequisites

1. **Terraform** >= 1.0 ([Install](https://terraform.io/downloads))
2. **AWS CLI** configured with credentials
3. **Docker** for building container images
4. **jq** for JSON processing

### Environment Setup

```bash
# Configure AWS credentials
aws configure

# Verify credentials
aws sts get-caller-identity
```

### Deployment Commands

```bash
# Plan infrastructure changes
npm run terraform:plan

# Deploy infrastructure only
npm run terraform:deploy

# Full deployment (infrastructure + images)
npm run aws:deploy

# Update services with new images
npm run terraform:update

# Show infrastructure status
npm run terraform:status

# Destroy infrastructure
npm run terraform:destroy
```

## 🔧 Configuration

### Environment Variables

You can override default values using environment variables:

```bash
export AWS_REGION=us-west-2
export ENVIRONMENT=dev
```

### Key Variables

Key variables in `environments/dev/terraform.tfvars`:

- **aws_region**: AWS region for deployment
- **environment**: Environment name (dev, staging, prod)
- **project_name**: Project identifier
- **vpc_cidr**: VPC CIDR block
- **service_names**: List of microservices
- **service_ports**: Port mapping for services
- **ecs_task_cpu/memory**: Resource allocation

## 🎯 Service Routing

The ALB routes traffic based on path patterns:

| Path Pattern | Service | Container Port |
|-------------|---------|---------------|
| `/users*` | user-service | 3001 |
| `/stores*` | store-service | 3002 |
| `/orders*` | order-service | 3003 |

## 📊 Auto Scaling

Services automatically scale based on:
- **CPU utilization** target: 70%
- **Min capacity**: 1 instance
- **Max capacity**: 10 instances (configurable)

## 🔐 Security Features

- Services run in private subnets
- ALB provides single public entry point
- Security groups restrict inter-service access
- IAM roles with minimal permissions
- ECR vulnerability scanning enabled

## 📈 Monitoring & Logging

- CloudWatch logs with 14-day retention
- ECS Container Insights enabled
- Application health checks at `/health`
- Load balancer health monitoring

## 🚨 Common Commands

```bash
# Initialize Terraform
cd infrastructure/terraform && terraform init

# Format and validate
terraform fmt && terraform validate

# Plan with specific environment
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply with auto-approval
terraform apply -auto-approve

# Show current state
terraform show

# List all resources
terraform state list

# Destroy all resources
terraform destroy -auto-approve
```

## 🧹 Cleanup

```bash
# Destroy infrastructure
npm run terraform:destroy

# Clean local state
rm -rf .terraform* terraform.tfstate*
``` 