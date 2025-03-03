# modules/ecs/variables.tf
# Input variables for the ECS module

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "demo-app"
}

variable "environment" {
  description = "Environment name (develop, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "container_image" {
  description = "Docker image to deploy (URL and tag)"
  type        = string
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256 # 0.25 vCPU
}

variable "container_memory" {
  description = "Memory for the container in MiB"
  type        = number
  default     = 512 # 0.5 GB
}

variable "desired_count" {
  description = "Number of instances of the task to run"
  type        = number
  default     = 2
}

# New variables for EC2 instances
variable "min_instances" {
  description = "Minimum number of EC2 instances in the ECS cluster"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of EC2 instances in the ECS cluster"
  type        = number
  default     = 2
}

variable "desired_instances" {
  description = "Desired number of EC2 instances in the ECS cluster"
  type        = number
  default     = 1
}