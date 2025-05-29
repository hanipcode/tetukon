# Provider configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment   = var.environment
      Project      = var.project_name
      ManagedBy    = "terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  environment           = var.environment
  project_name         = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  
  environment    = var.environment
  project_name   = var.project_name
  service_names  = var.service_names
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"
  
  environment         = var.environment
  project_name        = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  service_names      = var.service_names
  service_ports      = var.service_ports
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"
  
  environment            = var.environment
  project_name           = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arns     = module.alb.target_group_arns
  ecr_repository_urls   = module.ecr.repository_urls
  service_names         = var.service_names
  service_ports         = var.service_ports
  aws_region            = var.aws_region
} 