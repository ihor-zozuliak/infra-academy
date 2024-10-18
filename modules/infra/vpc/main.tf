# Module AWS VPC
# VPC resource
resource "aws_vpc" "vpc" {
  cidr_block                           = var.vpc_cidr
  instance_tenancy                     = var.tenancy
  enable_dns_support                   = var.dns_support
  enable_dns_hostnames                 = var.dns_hostnames
  enable_network_address_usage_metrics = var.tenancy
    Environment = var.environment
    Owner       = var.owner
    terraform   = "true"
  }
}

resource "aws_subnet" "vpc_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true
  ipv6_native =
}
resource "aws_internet_gateway" "vpc_ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Environment = var.environment
    Owner       = var.owner
    terraform   = "true"
  }
}
resource "aws_route_table" "vpc_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_ig.id
  }
  tags = {
    Environment = var.environment
    Owner       = var.owner
    terraform   = "true"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}
