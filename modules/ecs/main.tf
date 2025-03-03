# modules/ecs/main.tf
# Main file that imports other ECS components and defines locals

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
  
  # Names derived from project and environment
  cluster_name = "${var.project_name}-${var.environment}-cluster"
  service_name = "${var.project_name}-${var.environment}-service"
}