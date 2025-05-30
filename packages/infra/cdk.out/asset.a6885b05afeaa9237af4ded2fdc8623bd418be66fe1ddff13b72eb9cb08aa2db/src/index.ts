import express from 'express';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3003;

app.use(express.json());

// Health check route
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    service: 'order-service',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Default route
app.get('/', (req, res) => {
  res.json({
    message: 'Order Service API',
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Order Service running on port ${PORT}`);
  console.log(`📊 Health check available at http://localhost:${PORT}/health`);
}); 