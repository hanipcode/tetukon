import serverless from 'serverless-http';
import express from 'express';
import dotenv from 'dotenv';

dotenv.config();

const app = express();

app.use(express.json());

// Health check route
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    service: 'store-service',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    action: true
  });
});

// Default route
app.get('/', (req, res) => {
  res.json({
    message: 'Store Service API',
    version: '1.0.0'
  });
});

// Export the serverless handler with base path stripping
export const handler = serverless(app, {
  basePath: '/stores'
}); 