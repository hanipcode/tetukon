#!/bin/bash

# Terraform Deployment Script for Microservices
# This script builds, pushes to ECR, and deploys infrastructure using Terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
AWS_REGION=${AWS_REGION:-us-west-2}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")
ENVIRONMENT=${ENVIRONMENT:-dev}
TERRAFORM_DIR="infrastructure/terraform"
SERVICES=("user-service" "store-service" "order-service")

# Function to print colored output
print_status() { echo -e "${YELLOW}📋 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed"
        print_info "Install from: https://terraform.io/downloads"
        exit 1
    fi
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed"
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    # Check AWS credentials
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        print_error "AWS credentials not configured. Run 'aws configure'"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
    print_info "AWS Account ID: $AWS_ACCOUNT_ID"
    print_info "AWS Region: $AWS_REGION"
    print_info "Environment: $ENVIRONMENT"
}

# Initialize Terraform
terraform_init() {
    print_status "Initializing Terraform..."
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    terraform init -upgrade
    
    print_success "Terraform initialized"
    cd - > /dev/null
}

# Plan Terraform deployment
terraform_plan() {
    print_status "Planning Terraform deployment..."
    
    cd "$TERRAFORM_DIR"
    
    # Create terraform plan
    terraform plan \
        -var-file="environments/${ENVIRONMENT}/terraform.tfvars" \
        -var="aws_region=${AWS_REGION}" \
        -out="terraform.tfplan"
    
    print_success "Terraform plan created"
    cd - > /dev/null
}

# Apply Terraform deployment
terraform_apply() {
    print_status "Applying Terraform deployment..."
    
    cd "$TERRAFORM_DIR"
    
    # Apply terraform plan
    terraform apply -auto-approve "terraform.tfplan"
    
    print_success "Terraform applied successfully"
    cd - > /dev/null
}

# Get Terraform outputs
get_terraform_outputs() {
    print_status "Getting Terraform outputs..."
    
    cd "$TERRAFORM_DIR"
    
    # Get important outputs
    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "")
    ECR_URLS=$(terraform output -json ecr_repository_urls 2>/dev/null || echo "{}")
    
    if [ -n "$ALB_DNS" ]; then
        print_success "Infrastructure deployed successfully!"
        print_info "Service endpoints:"
        echo "  🌐 API Gateway: http://$ALB_DNS"
        echo "  👤 User Service: http://$ALB_DNS/users"
        echo "  🏪 Store Service: http://$ALB_DNS/stores"
        echo "  📦 Order Service: http://$ALB_DNS/orders"
        echo "  📊 Traefik Dashboard: http://$ALB_DNS:8080"
    fi
    
    cd - > /dev/null
}

# Build and push Docker images
build_and_push_images() {
    print_status "Building and pushing Docker images..."
    
    # Get ECR repository URLs from Terraform output
    cd "$TERRAFORM_DIR"
    ECR_URLS=$(terraform output -json ecr_repository_urls 2>/dev/null || echo "{}")
    cd - > /dev/null
    
    if [ "$ECR_URLS" = "{}" ]; then
        print_error "ECR repositories not found. Please run infrastructure deployment first."
        return 1
    fi
    
    # Login to ECR
    print_status "Logging in to ECR..."
    aws ecr get-login-password --region "$AWS_REGION" | \
        docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
    
    for service in "${SERVICES[@]}"; do
        print_status "Building and pushing $service..."
        
        # Extract ECR URL for this service
        ECR_URL=$(echo $ECR_URLS | jq -r ".\"$service\"" 2>/dev/null || echo "")
        
        if [ -z "$ECR_URL" ] || [ "$ECR_URL" = "null" ]; then
            ECR_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$service"
        fi
        
        # Build image
        docker build -t "$service" "apps/$service/"
        
        # Tag image for ECR
        docker tag "$service:latest" "$ECR_URL:latest"
        docker tag "$service:latest" "$ECR_URL:$(date +%Y%m%d-%H%M%S)"
        
        # Push images
        docker push "$ECR_URL:latest"
        docker push "$ECR_URL:$(date +%Y%m%d-%H%M%S)"
        
        print_success "Pushed $service to ECR"
    done
    
    print_success "All images pushed to ECR"
}

# Update ECS services
update_ecs_services() {
    print_status "Updating ECS services..."
    
    cd "$TERRAFORM_DIR"
    
    # Get cluster name and service names
    CLUSTER_NAME=$(terraform output -raw ecs_cluster_name 2>/dev/null || echo "")
    
    if [ -z "$CLUSTER_NAME" ]; then
        print_error "ECS cluster not found"
        return 1
    fi
    
    for service in "${SERVICES[@]}"; do
        print_status "Updating ECS service: $service..."
        
        # Force new deployment to pull latest images
        aws ecs update-service \
            --cluster "$CLUSTER_NAME" \
            --service "microservice-ecommerce-${ENVIRONMENT}-${service}" \
            --force-new-deployment \
            --region "$AWS_REGION" > /dev/null
            
        print_success "Updated ECS service: $service"
    done
    
    cd - > /dev/null
    print_success "All ECS services updated"
}

# Wait for services to be stable
wait_for_services() {
    print_status "Waiting for services to stabilize..."
    
    cd "$TERRAFORM_DIR"
    CLUSTER_NAME=$(terraform output -raw ecs_cluster_name 2>/dev/null || echo "")
    cd - > /dev/null
    
    if [ -z "$CLUSTER_NAME" ]; then
        print_error "ECS cluster not found"
        return 1
    fi
    
    for service in "${SERVICES[@]}"; do
        print_status "Waiting for $service to stabilize..."
        
        aws ecs wait services-stable \
            --cluster "$CLUSTER_NAME" \
            --services "microservice-ecommerce-${ENVIRONMENT}-${service}" \
            --region "$AWS_REGION"
            
        print_success "$service is stable"
    done
    
    print_success "All services are stable"
}

# Destroy infrastructure
destroy_infrastructure() {
    print_status "Destroying infrastructure..."
    
    cd "$TERRAFORM_DIR"
    
    terraform destroy \
        -var-file="environments/${ENVIRONMENT}/terraform.tfvars" \
        -var="aws_region=${AWS_REGION}" \
        -auto-approve
    
    print_success "Infrastructure destroyed"
    cd - > /dev/null
}

# Show infrastructure status
show_status() {
    print_status "Showing infrastructure status..."
    
    cd "$TERRAFORM_DIR"
    
    print_info "Terraform State:"
    terraform show -no-color | head -20
    
    print_info "Terraform Outputs:"
    terraform output
    
    cd - > /dev/null
}

# Show usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  plan           - Plan infrastructure changes"
    echo "  deploy         - Deploy infrastructure only"
    echo "  build-push     - Build and push images only"
    echo "  full-deploy    - Full deployment (infrastructure + images)"
    echo "  update         - Update services with new images"
    echo "  status         - Show infrastructure status"
    echo "  destroy        - Destroy infrastructure"
    echo ""
    echo "Environment variables:"
    echo "  AWS_REGION     - AWS region (default: us-west-2)"
    echo "  ENVIRONMENT    - Environment name (default: dev)"
    exit 1
}

# Main execution
case "${1:-full-deploy}" in
    "plan")
        check_prerequisites
        terraform_init
        terraform_plan
        ;;
    "deploy")
        check_prerequisites
        terraform_init
        terraform_plan
        terraform_apply
        get_terraform_outputs
        ;;
    "build-push")
        check_prerequisites
        build_and_push_images
        ;;
    "full-deploy")
        check_prerequisites
        terraform_init
        terraform_plan
        terraform_apply
        build_and_push_images
        update_ecs_services
        wait_for_services
        get_terraform_outputs
        ;;
    "update")
        check_prerequisites
        build_and_push_images
        update_ecs_services
        wait_for_services
        get_terraform_outputs
        ;;
    "status")
        show_status
        ;;
    "destroy")
        check_prerequisites
        destroy_infrastructure
        ;;
    *)
        usage
        ;;
esac 