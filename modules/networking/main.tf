# modules/networking/main.tf
# Main file that imports other networking components and defines locals

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = var.project_name
  }
  
  # VPC name derived from environment
  vpc_name = "${var.project_name}-${var.environment}-vpc"
}