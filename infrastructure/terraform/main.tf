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
  service_names  = concat(var.service_names, ["traefik"])  # Add traefik to services
}

# Application Load Balancer Module (public-facing)
module "alb" {
  source = "./modules/alb"
  
  environment         = var.environment
  project_name        = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  enable_https       = var.enable_https
  ssl_certificate_arn = var.ssl_certificate_arn
  domain_name        = var.domain_name
}

# Traefik Module (internal middleware)
module "traefik" {
  source = "./modules/traefik"
  
  environment         = var.environment
  project_name        = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  service_names      = var.service_names
  service_ports      = var.service_ports
  alb_security_group_id = module.alb.alb_security_group_id
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"
  
  environment              = var.environment
  project_name             = var.project_name
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  public_subnet_ids       = module.vpc.public_subnet_ids  # Traefik needs public access
  traefik_security_group_id = module.traefik.traefik_security_group_id
  traefik_target_group_arn = module.alb.traefik_target_group_arn
  ecr_repository_urls     = module.ecr.repository_urls
  service_names           = var.service_names
  service_ports           = var.service_ports
  aws_region              = var.aws_region
} 