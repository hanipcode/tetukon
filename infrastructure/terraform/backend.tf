# Backend configuration for Terraform state
# Uncomment and configure for production environments
# 
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "microservice-ecommerce/terraform.tfstate"
#     region         = "us-west-2"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }

# For local development, comment the above and use local backend
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
} 