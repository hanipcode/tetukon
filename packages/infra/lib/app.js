#!/usr/bin/env node
"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const cdk = __importStar(require("aws-cdk-lib"));
const lambda = __importStar(require("aws-cdk-lib/aws-lambda"));
const apigateway = __importStar(require("aws-cdk-lib/aws-apigateway"));
const app = new cdk.App();
const stack = new cdk.Stack(app, 'ECommerceStack');
// Create Lambda functions from existing services
const userServiceLambda = new lambda.Function(stack, 'UserService', {
    runtime: lambda.Runtime.NODEJS_18_X,
    handler: 'dist/handler.handler',
    code: lambda.Code.fromAsset('../../apps/user-service', {
        bundling: {
            image: lambda.Runtime.NODEJS_18_X.bundlingImage,
            command: [
                'bash', '-c', [
                    'cp -r /asset-input/* /asset-output/',
                    'cd /asset-output',
                    'npm config set cache /tmp/.npm',
                    'npm install --only=production --no-audit --no-fund'
                ].join(' && ')
            ],
            user: 'root',
        },
    }),
});
const storeServiceLambda = new lambda.Function(stack, 'StoreService', {
    runtime: lambda.Runtime.NODEJS_18_X,
    handler: 'dist/handler.handler',
    code: lambda.Code.fromAsset('../../apps/store-service', {
        bundling: {
            image: lambda.Runtime.NODEJS_18_X.bundlingImage,
            command: [
                'bash', '-c', [
                    'cp -r /asset-input/* /asset-output/',
                    'cd /asset-output',
                    'npm config set cache /tmp/.npm',
                    'npm install --only=production --no-audit --no-fund'
                ].join(' && ')
            ],
            user: 'root',
        },
    }),
});
const orderServiceLambda = new lambda.Function(stack, 'OrderService', {
    runtime: lambda.Runtime.NODEJS_18_X,
    handler: 'dist/handler.handler',
    code: lambda.Code.fromAsset('../../apps/order-service', {
        bundling: {
            image: lambda.Runtime.NODEJS_18_X.bundlingImage,
            command: [
                'bash', '-c', [
                    'cp -r /asset-input/* /asset-output/',
                    'cd /asset-output',
                    'npm config set cache /tmp/.npm',
                    'npm install --only=production --no-audit --no-fund'
                ].join(' && ')
            ],
            user: 'root',
        },
    }),
});
// Create API Gateway
const api = new apigateway.RestApi(stack, 'ECommerceApi', {
    restApiName: 'E-Commerce API',
});
// Add integrations for serverless-http
const userServiceResource = api.root.addResource('users');
userServiceResource.addMethod('ANY', new apigateway.LambdaIntegration(userServiceLambda));
userServiceResource.addProxy({
    defaultIntegration: new apigateway.LambdaIntegration(userServiceLambda),
    anyMethod: true,
});
const storeServiceResource = api.root.addResource('stores');
storeServiceResource.addMethod('ANY', new apigateway.LambdaIntegration(storeServiceLambda));
storeServiceResource.addProxy({
    defaultIntegration: new apigateway.LambdaIntegration(storeServiceLambda),
    anyMethod: true,
});
const orderServiceResource = api.root.addResource('orders');
orderServiceResource.addMethod('ANY', new apigateway.LambdaIntegration(orderServiceLambda));
orderServiceResource.addProxy({
    defaultIntegration: new apigateway.LambdaIntegration(orderServiceLambda),
    anyMethod: true,
});
new cdk.CfnOutput(stack, 'ApiUrl', {
    value: api.url,
});
