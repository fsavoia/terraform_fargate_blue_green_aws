resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

############################################
# Public configuration                     #
############################################

# Public subnet
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_block)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr_block, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-${element(var.availability_zones, count.index)}-public"
  }
}

# IGW - This will be used by the public subnets
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw"
  }
}

# Public subnets route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "${var.name}-rt-internet"
  }
}

# Associate the public route table to public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Public Security Groups - SG
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "public" {
  name        = "${var.name}-public-sg"
  description = "Public security group to allow inbound/outbound from the public connection"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    iterator = port
    for_each = var.public_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
      description = "VIVO Home IP - fsavoia"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
#tfsec:ignore:aws-vpc-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
    description = "Default outbound traffic for public subnet"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}-public-sg"
  }

}

############################################
# Private configuration                    #
############################################

# Private subnets
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.private_subnet_cidr_block)
  cidr_block              = element(var.private_subnet_cidr_block, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-${element(var.availability_zones, count.index)}-private"
  }
}

# elastic ip for the nat gateway
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

# Nat gateway for the private subnets
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name = "${var.name}-natgw"
  }
}

# Private subnets route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.name}-private-route-table"
  }
}

# Associate the private route table to private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr_block)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Private Security Groups - SG
resource "aws_security_group" "private" {
  name        = "${var.name}-private-sg"
  vpc_id      = aws_vpc.main.id
  description = "Private security group to allow inbound/outbound from the VPC"

  dynamic "ingress" {
    iterator = port
    for_each = var.private_ports
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Default inbound traffic for private subnet"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
#tfsec:ignore:aws-vpc-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
    description = "Default outbound traffic for private subnet"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}-private-sg"
  }

}

