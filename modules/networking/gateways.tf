# modules/networking/gateways.tf
# Defines Internet Gateway and NAT instances for internet connectivity

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

# Get the latest Amazon Linux 2 AMI for NAT instances
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group for NAT instances
resource "aws_security_group" "nat_instance" {
  name        = "${var.project_name}-${var.environment}-nat-instance-sg"
  description = "Security group for NAT instances"
  vpc_id      = aws_vpc.this.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all inbound traffic from the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-instance-sg"
    }
  )
}

# NAT instances instead of NAT Gateways
resource "aws_instance" "nat" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"  # Free tier eligible
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.nat_instance.id]
  source_dest_check      = false  # Required for NAT functionality
  
  user_data = <<-EOF
    #!/bin/bash
    # Enable IP forwarding
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    
    # NAT configuration with iptables
    yum install -y iptables-services
    systemctl enable iptables
    systemctl start iptables
    
    # Configure iptables for NAT
    iptables -t nat -A POSTROUTING -o eth0 -s ${var.vpc_cidr} -j MASQUERADE
    iptables-save > /etc/sysconfig/iptables
    
    # Make sure the instance boots with this configuration
    echo "#!/bin/bash" > /etc/rc.local
    echo "iptables -t nat -A POSTROUTING -o eth0 -s ${var.vpc_cidr} -j MASQUERADE" >> /etc/rc.local
    chmod +x /etc/rc.local
  EOF

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-instance-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# Elastic IPs for NAT instances
resource "aws_eip" "nat" {
  count      = length(aws_instance.nat)
  domain     = "vpc"
  instance   = aws_instance.nat[count.index].id
  depends_on = [aws_internet_gateway.this]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
    }
  )
}