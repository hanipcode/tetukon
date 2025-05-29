#!/bin/bash

# Build and Deploy Microservices Infrastructure
# Usage: ./scripts/build-and-deploy.sh [local|aws]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DEPLOYMENT_MODE=${1:-local}
PROJECT_NAME="microservice-e-commerce"

echo -e "${GREEN}🚀 Starting deployment for ${DEPLOYMENT_MODE} environment${NC}"

# Function to print status
print_status() {
    echo -e "${YELLOW}📋 $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_success "Docker is running"
}

# Build all services
build_services() {
    print_status "Building all microservices..."
    
    # Build user service
    print_status "Building user-service..."
    cd apps/user-service
    npm run build
    cd ../..
    
    # Build store service
    print_status "Building store-service..."
    cd apps/store-service
    npm run build
    cd ../..
    
    # Build order service
    print_status "Building order-service..."
    cd apps/order-service
    npm run build
    cd ../..
    
    print_success "All services built successfully"
}

# Deploy locally with Docker Compose
deploy_local() {
    print_status "Deploying to local environment with Docker Compose..."
    
    # Stop existing containers
    print_status "Stopping existing containers..."
    docker-compose down --remove-orphans || true
    
    # Build and start containers
    print_status "Building and starting containers..."
    docker-compose up --build -d
    
    # Wait for services to be healthy
    print_status "Waiting for services to be healthy..."
    sleep 30
    
    # Check service health
    check_service_health
    
    print_success "Local deployment completed successfully!"
    print_status "Services are available at:"
    echo "  🌐 API Gateway: http://localhost:8000"
    echo "  📊 Traefik Dashboard: http://localhost:8080"
    echo "  👤 User Service: http://localhost:8000/users"
    echo "  🏪 Store Service: http://localhost:8000/stores"
    echo "  📦 Order Service: http://localhost:8000/orders"
}

# Check service health
check_service_health() {
    print_status "Checking service health..."
    
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        print_status "Health check attempt $attempt/$max_attempts..."
        
        if curl -f -s http://localhost:8000/users/health > /dev/null && \
           curl -f -s http://localhost:8000/stores/health > /dev/null && \
           curl -f -s http://localhost:8000/orders/health > /dev/null; then
            print_success "All services are healthy!"
            return 0
        fi
        
        sleep 10
        ((attempt++))
    done
    
    print_error "Health check failed after $max_attempts attempts"
    return 1
}

# Deploy to AWS (placeholder for now)
deploy_aws() {
    print_status "Preparing AWS deployment..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it and configure your credentials."
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        print_error "AWS credentials are not configured. Please run 'aws configure'."
        exit 1
    fi
    
    print_status "AWS deployment will be implemented with terraform/cloudformation"
    print_status "For now, you can use the docker-compose.aws.yml file with ECS CLI"
    
    echo "To deploy to AWS ECS:"
    echo "1. Configure your AWS credentials"
    echo "2. Create ECR repositories for each service"
    echo "3. Build and push images to ECR"
    echo "4. Use the infrastructure/aws/docker-compose.aws.yml file"
    echo "5. Deploy using ECS CLI or AWS CloudFormation"
}

# Main execution
main() {
    check_docker
    
    case $DEPLOYMENT_MODE in
        "local")
            build_services
            deploy_local
            ;;
        "aws")
            build_services
            deploy_aws
            ;;
        *)
            print_error "Unknown deployment mode: $DEPLOYMENT_MODE"
            echo "Usage: $0 [local|aws]"
            exit 1
            ;;
    esac
}

# Run main function
main 