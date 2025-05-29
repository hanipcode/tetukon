# Microservice E-Commerce Platform

A modern, scalable microservices architecture built with TypeScript, Express.js, and Next.js for local development.

## 🏗️ Architecture

### Local Development
- **Frontend**: Next.js application (Port 3000)
- **User Service**: Express.js API (Port 3001)
- **Store Service**: Express.js API (Port 3002)
- **Order Service**: Express.js API (Port 3003)
- **Communication**: Direct HTTP calls between services

## 📁 Project Structure

```
microservice-e-commerce/
├── apps/                          # Applications
│   ├── user-service/             # User management service
│   ├── store-service/            # Store/product management
│   ├── order-service/            # Order processing
│   └── frontend/                 # Next.js web application
├── packages/                     # Shared packages (if any)
├── package.json                  # Workspace configuration
└── turbo.json                    # Monorepo build configuration
```

## 🚀 Quick Start

### Prerequisites
- Node.js >= 18
- npm >= 9

### Installation & Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start all services in development mode:**
   ```bash
   npm run dev
   ```

3. **Access services:**
   - 🖥️ **Frontend**: http://localhost:3000
   - 👤 **User Service**: http://localhost:3001
   - 🏪 **Store Service**: http://localhost:3002
   - 📦 **Order Service**: http://localhost:3003

### Individual Service Commands

You can also start services individually:

```bash
# Start user service only
cd apps/user-service && npm run dev

# Start store service only
cd apps/store-service && npm run dev

# Start order service only
cd apps/order-service && npm run dev

# Start frontend only
cd apps/frontend && npm run dev
```

## 🛠️ Services

### User Service (Port 3001)
- User registration and authentication
- Profile management
- **Health check**: `GET http://localhost:3001/health`
- **API root**: `GET http://localhost:3001/`

### Store Service (Port 3002)
- Product catalog management
- Store information
- **Health check**: `GET http://localhost:3002/health`
- **API root**: `GET http://localhost:3002/`

### Order Service (Port 3003)
- Order processing and management
- Order history
- **Health check**: `GET http://localhost:3003/health`
- **API root**: `GET http://localhost:3003/`

### Frontend (Port 3000)
- Next.js web application
- Server-side rendering
- Modern React with TypeScript
- **Access**: http://localhost:3000

## 🔧 Development Commands

### Workspace Commands
```bash
npm run build          # Build all services
npm run dev            # Start all development servers
npm run start          # Start all production builds
npm run lint           # Lint all services
npm run type-check     # TypeScript type checking
npm run clean          # Clean build artifacts
npm run format         # Format code with Prettier
```

### Individual Service Commands
Each service supports these commands:
```bash
npm run build          # Build the service
npm run dev            # Start development server with hot reload
npm run start          # Start production build
npm run clean          # Clean build artifacts
npm run type-check     # TypeScript type checking
```

## 🌐 API Endpoints

### User Service (http://localhost:3001)
- `GET /health` - Health check
- `GET /` - Service information

### Store Service (http://localhost:3002)
- `GET /health` - Health check
- `GET /` - Service information

### Order Service (http://localhost:3003)
- `GET /health` - Health check
- `GET /` - Service information

## 🔧 Configuration

Each service uses environment variables for configuration:

### User Service (.env)
```
PORT=3001
NODE_ENV=development
```

### Store Service (.env)
```
PORT=3002
NODE_ENV=development
```

### Order Service (.env)
```
PORT=3003
NODE_ENV=development
```

## 🚀 Development Workflow

1. **Start all services**: `npm run dev`
2. **Make changes**: Edit code in any service
3. **Hot reload**: Services automatically restart on changes
4. **Test endpoints**: Use the health check endpoints to verify services
5. **Build for production**: `npm run build`

## 📊 Monitoring & Debugging

### Health Checks
Each service provides a health check endpoint:
- User Service: http://localhost:3001/health
- Store Service: http://localhost:3002/health
- Order Service: http://localhost:3003/health

### Logs
- Each service logs to console with service identification
- Use `npm run dev` to see all service logs in one terminal
- Or start services individually to see isolated logs

## 🏗️ Adding New Services

1. Create a new directory in `apps/`
2. Initialize with `package.json` similar to existing services
3. Add TypeScript configuration
4. Create Express.js server with health check endpoint
5. Add to workspace in root `package.json`
6. Update this README

## 🔄 Inter-Service Communication

Services can communicate with each other using HTTP requests:

```typescript
// Example: User service calling Store service
const response = await fetch('http://localhost:3002/stores');
const stores = await response.json();
```

## 🛠️ Technology Stack

- **Runtime**: Node.js
- **Language**: TypeScript
- **Backend Framework**: Express.js
- **Frontend Framework**: Next.js + React
- **Build Tool**: Turbo (monorepo)
- **Package Manager**: npm
- **Code Formatting**: Prettier
- **Development**: Hot reload with nodemon/Next.js dev server
