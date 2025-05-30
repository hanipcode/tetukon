#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';

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