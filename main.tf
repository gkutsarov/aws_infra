terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

provider "aws" {
  region = "us-west-2"
}

# Create the VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Solar System"
  }
}

### PUBLIC SUBNET A ###
resource "aws_subnet" "public_subnet_a" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet A"
  }
}

### PUBLIC SUBNET B ###
resource "aws_subnet" "public_subnet_b" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet B"
  }
}

### PUBLIC SUBNET C ###
resource "aws_subnet" "public_subnet_c" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet C"
  }
}

### INTERNET GATEWAY ###
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MY IGW"
  }
}

### PUBLIC ROUTE TABLE ***
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Public Route Table"
  }
}

### ENABLE INTERNET ACCESS ###
resource "aws_route" "public_internet_route" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_igw.id
}

### ROUTE TABLE SUBNET ASSOCIATION PUBLIC SUBNET A ###
resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

### ROUTE TABLE SUBNET ASSOCIATION PUBLIC SUBNET B ###
resource "aws_route_table_association" "public_subnet_association_b" {
  subnet_id = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

### ROUTE TABLE SUBNET ASSOCIATION PUBLIC SUBNET C ###
resource "aws_route_table_association" "public_subnet_association_c" {
  subnet_id = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public_rt.id
}

### CREATE ELASTIC IP FOR NAT GATEWAY ###
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

### CREATE NAT GATEWAY IN PUBLIC SUBNET A ###
resource "aws_nat_gateway" "aws_nat_gateway_a" {
  allocation_id =  aws_eip.nat_eip.id  # Associate the NAT Gateway with the Elastic IP
  subnet_id = aws_subnet.public_subnet_a.id # Public Subnet A where the NAT Gateway will be created

  tags = {
    Name = "NAT GATEWAY"
  }
  depends_on = [aws_internet_gateway.my_igw]
}

### PRIVATE SUBNET A ###
resource "aws_subnet" "private_subnet_a" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "Private Subnet A"
  }
}

### PRIVATE SUBNET B ###
resource "aws_subnet" "private_subnet_b" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "Private Subnet B"
  }
}

### PRIVATE SUBNET C ###
resource "aws_subnet" "private_subnet_c" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "Private Subnet C"
  }
}

### ROUTE TABLE FOR PRIVATE SUBNETS ###
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Private Route Table"
  }
}

### ROUTE TABLE SUBNET ASSOCIATION PRIVATE SUBNET A ###
resource "aws_route_table_association" "private_subnet_association_a" {
  subnet_id = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

### ROUTE TABLE SUBNET ASSOCIATION PRIVATE SUBNET B ###
resource "aws_route_table_association" "private_subnet_association_b" {
  subnet_id = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

### ROUTE TABLE SUBNET ASSOCIATION PRIVATE SUBNET CC ###
resource "aws_route_table_association" "private_subnet_association_c" {
  subnet_id = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private_rt.id
}

### CREATE PRIVATE ROUTE53 ZONE ###
resource "aws_route53_zone" "private_zone" {
  name = "internal.zone.com"
  vpc {
    vpc_id = aws_vpc.my_vpc.id # Associate the zone with the VPC
  }
}


