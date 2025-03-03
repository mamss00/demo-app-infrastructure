# modules/networking/vpc.tf
# Defines the main VPC for the environment

resource "aws_vpc" "this" {
  # CIDR block for the VPC
  cidr_block = var.vpc_cidr
  
  # Enable DNS hostnames for the VPC resources
  enable_dns_hostnames = true
  
  # Enable DNS support
  enable_dns_support = true
  
  # Assign common tags plus a Name tag
  tags = merge(
    local.common_tags,
    {
      Name = local.vpc_name
    }
  )
}