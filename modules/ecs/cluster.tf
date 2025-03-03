# modules/ecs/cluster.tf
# Defines the ECS cluster and related resources

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  # Enable Container Insights for monitoring (only in prod by default)
  setting {
    name  = "containerInsights"
    value = var.environment == "prod" ? "enabled" : "disabled"
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.cluster_name
    }
  )
}

# CloudWatch Log Group for container logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  # Keep logs longer in production
  retention_in_days = var.environment == "prod" ? 30 : 7

  tags = merge(
    local.common_tags,
    {
      Name = "/ecs/${var.project_name}-${var.environment}"
    }
  )
}