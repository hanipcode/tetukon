# Microservice E-Commerce Platform

A modern, scalable microservices architecture built with TypeScript, Express.js, Next.js, and deployed using Docker containers with Traefik API Gateway for local development and AWS ECS Fargate with Terraform for production.

## 🏗️ Architecture

### Local Development
- **API Gateway**: Traefik (localhost:8000)
- **Services**: Docker containers with hot reload
- **Routing**: Path-based routing with prefix stripping

### Production (AWS)
- **Infrastructure**: Terraform-managed AWS resources
- **Container Orchestration**: ECS Fargate
- **Load Balancing**: Application Load Balancer
- **Container Registry**: ECR
- **Networking**: VPC with public/private subnets
- **Monitoring**: CloudWatch Logs & Container Insights

## 📁 Project Structure

```
microservice-e-commerce/
├── apps/                          # Microservices
│   ├── user-service/             # User management service
│   ├── store-service/            # Store/product management
│   ├── order-service/            # Order processing
│   └── frontend/                 # Next.js web application
├── infrastructure/               # Infrastructure as Code
│   ├── traefik/                 # Local API Gateway config
│   └── terraform/               # AWS infrastructure
│       ├── modules/             # Reusable Terraform modules
│       └── environments/        # Environment-specific configs
├── scripts/                     # Deployment scripts
│   ├── build-and-deploy.sh     # Local deployment
│   └── terraform-deploy.sh     # AWS deployment
├── docker-compose.yml          # Local development
├── package.json                # Workspace configuration
└── turbo.json                  # Monorepo build configuration
```

## 🚀 Quick Start

### Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start all services:**
   ```bash
   npm run dev
   # or for infrastructure deployment
   npm run infra:deploy-local
   ```

3. **Access services:**
   - 🌐 **API Gateway**: http://localhost:8000
   - 📊 **Traefik Dashboard**: http://localhost:8080
   - 🖥️ **Frontend**: http://localhost:3000
   - 👤 **User Service**: http://localhost:8000/users
   - 🏪 **Store Service**: http://localhost:8000/stores
   - 📦 **Order Service**: http://localhost:8000/orders

### AWS Production Deployment

1. **Prerequisites:**
   - AWS CLI configured
   - Terraform >= 1.0 installed
   - Docker installed

2. **Deploy to AWS:**
   ```bash
   # Plan infrastructure changes
   npm run terraform:plan
   
   # Full deployment (infrastructure + images)
   npm run aws:deploy
   
   # Update services only
   npm run terraform:update
   ```

3. **Access production services:**
   - Services available at ALB DNS name (output from Terraform)

## 🛠️ Services

### User Service (Port 3001)
- User registration and authentication
- Profile management
- Health check endpoint: `/health`

### Store Service (Port 3002)
- Product catalog management
- Store information
- Health check endpoint: `/health`

### Order Service (Port 3003)
- Order processing and management
- Order history
- Health check endpoint: `/health`

### Frontend (Port 3000)
- Next.js web application
- Server-side rendering
- Modern React with TypeScript

## 🔧 Development Commands

### Workspace Commands
```bash
npm run build          # Build all services
npm run dev            # Start development servers
npm run lint           # Lint all services
npm run type-check     # TypeScript type checking
npm run clean          # Clean build artifacts
```

### Docker Commands
```bash
npm run docker:build  # Build all Docker images
npm run docker:up     # Start containers
npm run docker:down   # Stop containers
npm run docker:logs   # View container logs
```

### Infrastructure Commands
```bash
# Local Development
npm run infra:deploy-local     # Deploy with Traefik

# AWS Production
npm run terraform:plan         # Plan infrastructure changes
npm run terraform:deploy       # Deploy infrastructure only
npm run aws:deploy            # Full deployment
npm run terraform:update      # Update services
npm run terraform:status      # Show infrastructure status
npm run terraform:destroy     # Destroy infrastructure
```

## 🌐 API Endpoints

### Through API Gateway (Local: localhost:8000, AWS: ALB DNS)

#### User Service
- `GET /users/health` - Health check
- `GET /users` - List users
- `POST /users` - Create user
- `GET /users/:id` - Get user by ID

#### Store Service
- `GET /stores/health` - Health check
- `GET /stores` - List stores
- `POST /stores` - Create store
- `GET /stores/:id` - Get store by ID

#### Order Service
- `GET /orders/health` - Health check
- `GET /orders` - List orders
- `POST /orders` - Create order
- `GET /orders/:id` - Get order by ID

## 🔒 Security Features

### Local Development
- Services isolated in Docker network
- No direct external access to services
- Traefik handles all external traffic

### Production (AWS)
- Services in private subnets
- ALB as single public entry point
- Security groups with least privilege
- IAM roles with minimal permissions
- ECR vulnerability scanning
- VPC with NAT gateways for outbound access

## 📊 Monitoring & Observability

### Local Development
- Traefik dashboard for routing visualization
- Docker logs for debugging
- Health check endpoints for service status

### Production (AWS)
- CloudWatch Logs for application logs
- ECS Container Insights for metrics
- ALB access logs
- Auto scaling based on CPU utilization
- Health checks with automatic recovery

## 🚀 Deployment Strategies

### Local Development
1. **Hot Reload**: Automatic restart on code changes
2. **Volume Mounting**: Live code updates without rebuilds
3. **Service Discovery**: Automatic service registration with Traefik

### Production (AWS)
1. **Blue-Green Deployment**: Zero-downtime deployments
2. **Auto Scaling**: Horizontal scaling based on metrics
3. **Health Checks**: Automatic unhealthy task replacement
4. **Rolling Updates**: Gradual service updates

## 🔧 Configuration

### Environment Variables

Each service supports these environment variables:

```bash
# Common
PORT=3001|3002|3003    # Service port
NODE_ENV=development|production

# Service-specific
DATABASE_URL=...       # Database connection
API_KEY=...           # External API keys
```

### Infrastructure Configuration

Terraform variables in `infrastructure/terraform/environments/`:

```hcl
# Development (dev/terraform.tfvars)
ecs_desired_count = 1
ecs_task_cpu      = 256
ecs_task_memory   = 512

# Production (prod/terraform.tfvars)
ecs_desired_count = 3
ecs_task_cpu      = 512
ecs_task_memory   = 1024
```

## 🧪 Testing

```bash
# Run tests for all services
npm run test

# Run tests for specific service
npm run test --workspace=user-service

# Health check tests
curl http://localhost:8000/users/health
curl http://localhost:8000/stores/health
curl http://localhost:8000/orders/health
```

## 📚 Documentation

- [Infrastructure Setup](./infrastructure/README.md) - Detailed infrastructure documentation
- [Terraform Configuration](./infrastructure/terraform/README.md) - Terraform-specific documentation
- [Local Development](./docs/local-development.md) - Development environment setup
- [API Documentation](./docs/api.md) - Complete API reference

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📧 Email: support@example.com
- 💬 Discord: [Join our community](https://discord.gg/example)
- 📖 Documentation: [docs.example.com](https://docs.example.com)
- 🐛 Issues: [GitHub Issues](https://github.com/username/microservice-e-commerce/issues)
