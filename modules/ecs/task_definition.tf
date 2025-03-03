# modules/ecs/task_definition.tf
# Defines the ECS task definition

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}"
  # Changed from awsvpc (Fargate) to bridge (EC2)
  network_mode             = "bridge"  
  # CPU and memory constraints are optional for EC2 but recommended
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  # Container definition
  container_definitions = jsonencode([
    {
      name         = "${var.project_name}-${var.environment}"
      image        = var.container_image
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0  # Dynamic port mapping for EC2
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      ]
    }
  ])

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-task"
    }
  )
}