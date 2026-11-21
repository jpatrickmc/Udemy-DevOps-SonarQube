terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-2"
}

 # Create VPC
  resource "aws_vpc" "Lab-VPC" {
    # classless inter-domain routing (CIDR) block for the VPC
    # cidr_block = "172.0.0.0/16"
    cidr_block = var.cidr_block[0]

    tags = {
      Name = "Lab-VPC"
    }
  }

  # Create Subnet (public)
  resource "aws_subnet" "Lab-Public-Subnet1" {
    vpc_id     = aws_vpc.Lab-VPC.id
    # cidr_block = "172.0.1.0/24"
    cidr_block = var.cidr_block[1]

    tags = {
      Name = "Lab-Public-Subnet1"
    }
  }

  # Create Subnet (private)
#   resource "aws_subnet" "Lab-Private-Subnet2" {
#     vpc_id     = aws_vpc.Lab-VPC.id
#     cidr_block = "172.0.2.0/24"

#     tags = {
#       Name = "Lab-Private-Subnet2"
#     }
#   }

# Create Internet Gateway
resource "aws_internet_gateway" "Lab-IGW" {
  vpc_id = aws_vpc.Lab-VPC.id

  tags = {
    Name = "Lab-IGW"
  }
}

# Create Security Group
resource "aws_security_group" "Lab-SG" {
  name        = "Lab-SG"
  description = "Security group to allow inbound and outbound traffic for Lab VPC"
  vpc_id      = aws_vpc.Lab-VPC.id

# Allow inbound SSH traffic on port 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to any destination
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lab-SG"
  }
}

# Create route table and associate it with the public subnet
resource "aws_route_table" "Lab-Public-RT" {
  vpc_id = aws_vpc.Lab-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Lab-IGW.id
  }

  tags = {
    Name = "Lab-Public-RT"
  }
}

resource "aws_route_table_association" "Lab-Public-RT-Assoc" {
  subnet_id      = aws_subnet.Lab-Public-Subnet1.id
  route_table_id = aws_route_table.Lab-Public-RT.id
}