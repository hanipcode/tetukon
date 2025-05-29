# Infrastructure Setup for Microservice E-Commerce

This directory contains the infrastructure configuration for deploying the microservice e-commerce platform both locally and on AWS.

## 🏗️ Architecture Overview

The infrastructure uses:
- **Traefik** as the API Gateway for local development
- **Application Load Balancer (ALB)** for AWS deployment
- **Docker** containers for all services
- **AWS ECS Fargate** for serverless container deployment
- **Terraform** for Infrastructure as Code

## 📁 Directory Structure

```
infrastructure/
├── traefik/                    # Traefik configuration for local dev
│   ├── traefik.yml            # Static configuration
│   └── dynamic.yml            # Dynamic routing configuration
├── terraform/                 # Terraform Infrastructure as Code
│   ├── main.tf               # Root module
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output values
│   ├── modules/              # Reusable modules
│   │   ├── vpc/             # VPC and networking
│   │   ├── ecr/             # Container registry
│   │   ├── alb/             # Application Load Balancer
│   │   └── ecs/             # Container orchestration
│   └── environments/        # Environment configurations
│       └── dev/
│           └── terraform.tfvars
├── aws/                       # AWS deployment configuration
│   └── docker-compose.aws.yml # ECS-specific compose file
└── README.md                  # This file
```

## 🚀 Local Development with Traefik

### Quick Start

1. **Build and start all services:**
   ```bash
   npm run infra:deploy-local
   # or
   ./scripts/build-and-deploy.sh local
   ```

2. **Access services via API Gateway:**
   - 🌐 **API Gateway**: http://localhost:8000
   - 📊 **Traefik Dashboard**: http://localhost:8080
   - 👤 **User Service**: http://localhost:8000/users
   - 🏪 **Store Service**: http://localhost:8000/stores
   - 📦 **Order Service**: http://localhost:8000/orders

### Manual Docker Commands

```bash
# Build all images
docker-compose build

# Start services in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Service Routing

Traefik routes requests based on path prefixes:

| Path | Service | Internal URL |
|------|---------|-------------|
| `/users/*` | user-service | `http://user-service:3001` |
| `/stores/*` | store-service | `http://store-service:3002` |
| `/orders/*` | order-service | `http://order-service:3003` |

The path prefixes are stripped before forwarding to services, so:
- `GET /users/health` → `GET /health` on user-service
- `GET /stores/health` → `GET /health` on store-service

## ☁️ AWS Deployment with Terraform

### Prerequisites

1. **Terraform** >= 1.0 ([Install](https://terraform.io/downloads))
2. **AWS CLI** configured with credentials
3. **Docker** for building container images
4. **jq** for JSON processing

### Quick Deployment

```bash
# Plan infrastructure changes
npm run terraform:plan

# Full deployment (infrastructure + images)
npm run aws:deploy

# Update services with new images
npm run terraform:update

# Destroy infrastructure
npm run terraform:destroy
```

### Manual Terraform Commands

```bash
# Initialize Terraform
cd infrastructure/terraform
terraform init

# Plan changes
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply changes
terraform apply -auto-approve

# Show outputs
terraform output
```

### AWS Architecture

The Terraform configuration creates:

1. **VPC with public/private subnets** across 2 AZs
2. **Internet Gateway and NAT Gateways** for connectivity
3. **Application Load Balancer** in public subnets
4. **ECS Fargate Cluster** in private subnets
5. **ECR repositories** for container images
6. **Target Groups** for each microservice
7. **Listener Rules** for path-based routing
8. **Security Groups** with least privilege access
9. **CloudWatch Log Groups** for application logs
10. **Auto Scaling** policies for horizontal scaling

### AWS Service Endpoints

After deployment, services will be available at:
- **Load Balancer DNS**: Output from `terraform output alb_dns_name`
- **User Service**: `http://{alb-dns}/users`
- **Store Service**: `http://{alb-dns}/stores`
- **Order Service**: `http://{alb-dns}/orders`

## 🔧 Configuration

### Environment Variables

Each service uses these environment variables:

```bash
PORT=3001|3002|3003    # Service port
NODE_ENV=production    # Runtime environment
```

### Traefik Configuration

- **Static Config** (`traefik.yml`): Entry points, providers, logging
- **Dynamic Config** (`dynamic.yml`): Routing rules, middlewares, services

### Terraform Configuration

Key variables in `terraform/environments/dev/terraform.tfvars`:

```hcl
aws_region   = "us-west-2"
environment  = "dev"
project_name = "microservice-ecommerce"

# VPC Configuration
vpc_cidr = "10.192.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

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
ecs_desired_count = 1
```

### Health Checks

All services implement health check endpoints:
- **Path**: `/health`
- **Response**: JSON with service status, timestamp, and uptime

## 📊 Monitoring & Logging

### Local Development
- Traefik dashboard at http://localhost:8080
- Docker logs: `docker-compose logs -f [service-name]`

### AWS Production
- CloudWatch Logs for application logs
- ECS Container Insights for metrics
- ALB access logs (optional)
- Auto scaling based on CPU utilization

## 🔐 Security Considerations

### Local Development
- Services are isolated in Docker network
- No external port exposure except through Traefik

### AWS Production
- Services run in private subnets
- ALB provides SSL termination capability
- Security groups restrict access
- IAM roles with minimal permissions
- Container images scanned for vulnerabilities

## 📈 Scaling

### Local Development
- Services can be scaled using Docker Compose:
  ```bash
  docker-compose up --scale user-service=3
  ```

### AWS Production
- ECS Service Auto Scaling based on CPU/memory
- ALB automatically distributes traffic
- Terraform supports updating desired counts
- Auto scaling policies with configurable thresholds

## 🚨 Troubleshooting

### Common Issues

1. **Services not accessible through Traefik:**
   - Check if containers are running: `docker-compose ps`
   - Verify network connectivity: `docker network ls`
   - Check Traefik logs: `docker-compose logs traefik`

2. **Terraform deployment fails:**
   - Verify AWS credentials: `aws sts get-caller-identity`
   - Check IAM permissions
   - Validate Terraform configuration: `terraform validate`

3. **Health checks failing:**
   - Verify service is responding on health endpoint
   - Check service logs for errors
   - Ensure correct port configuration

### Debugging Commands

```bash
# Check service health locally
curl http://localhost:8000/users/health
curl http://localhost:8000/stores/health
curl http://localhost:8000/orders/health

# View Traefik configuration
curl http://localhost:8080/api/http/routers
curl http://localhost:8080/api/http/services

# Check container status
docker-compose ps
docker-compose logs [service-name]

# Terraform debugging
cd infrastructure/terraform
terraform validate
terraform plan
terraform output
terraform state list

# AWS debugging
aws ecs describe-services --cluster microservice-ecommerce-dev-cluster
aws logs get-log-events --log-group-name /ecs/microservice-ecommerce-dev/user-service
```

## 🧹 Cleanup

### Local Environment
```bash
docker-compose down --volumes --remove-orphans
docker system prune
```

### AWS Environment
```bash
# Destroy Terraform infrastructure
npm run terraform:destroy

# Clean up local Terraform state
cd infrastructure/terraform
rm -rf .terraform* terraform.tfstate*
```

## 🔄 CI/CD Integration

This infrastructure can be integrated with CI/CD pipelines:

1. **GitHub Actions**: Use AWS credentials in secrets
2. **GitLab CI**: Configure AWS CLI in pipeline
3. **Jenkins**: Use AWS plugins for deployment

Example GitHub Actions workflow:

```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2
      - name: Deploy
        run: npm run aws:deploy
```

## 📚 Documentation

- [Terraform Configuration](./terraform/README.md) - Detailed Terraform documentation
- [Traefik Configuration](./traefik/) - API Gateway setup for local development
- [AWS Best Practices](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html) - AWS Well-Architected Framework

## 🎯 Next Steps

1. **Production Setup**: Configure remote Terraform state with S3 backend
2. **HTTPS**: Add SSL certificates and configure HTTPS listeners
3. **Domain Setup**: Configure Route 53 for custom domain routing
4. **Monitoring**: Add CloudWatch dashboards and alerts
5. **Backup**: Implement automated backup strategies
6. **Security**: Add WAF rules and security headers 