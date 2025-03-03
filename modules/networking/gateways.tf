# modules/networking/gateways.tf
# Defines Internet Gateway and NAT Gateways for internet connectivity

# Internet Gateway - allows communication between VPC and internet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  # In dev, we use only one NAT Gateway for cost savings
  # In prod, we use one NAT Gateway per AZ for high availability
  count  = var.single_nat_gateway ? 1 : length(var.private_subnets)
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
    }
  )

  # Depends on Internet Gateway to ensure proper order of creation
  depends_on = [aws_internet_gateway.this]
}

# NAT Gateways - allow private subnets to access internet
resource "aws_nat_gateway" "this" {
  count = var.single_nat_gateway ? 1 : length(var.private_subnets)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
    }
  )

  # Depends on Internet Gateway to ensure proper order of creation
  depends_on = [aws_internet_gateway.this]
}