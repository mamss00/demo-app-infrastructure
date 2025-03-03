# modules/ecr/variables.tf
# Input variables for the ECR module

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "demo-app"
}

variable "environment" {
  description = "Environment name (develop, staging, prod)"
  type        = string
}