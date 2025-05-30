"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
const serverless_http_1 = __importDefault(require("serverless-http"));
const express_1 = __importDefault(require("express"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app = (0, express_1.default)();
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
// Export the serverless handler
exports.handler = (0, serverless_http_1.default)(app);
