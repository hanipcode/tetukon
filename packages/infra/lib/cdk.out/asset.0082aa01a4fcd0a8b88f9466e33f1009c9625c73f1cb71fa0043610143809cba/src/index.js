"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3002;
app.use(express_1.default.json());
// Health check route
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'OK',
        service: 'store-service',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});
// Default route
app.get('/', (req, res) => {
    res.json({
        message: 'Store Service API',
        version: '1.0.0'
    });
});
app.listen(PORT, () => {
    console.log(`🚀 Store Service running on port ${PORT}`);
    console.log(`📊 Health check available at http://localhost:${PORT}/health`);
});
