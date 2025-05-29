# Backend configuration for Terraform state
# For production/staging, use S3 backend (commented out for now):
# 
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "microservice-ecommerce/terraform.tfstate"
#     region         = "ap-southeast-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }

# For local development and CI/CD, use local backend
# This works for both local development and GitHub Actions
terraform {
  backend "local" {}
} 