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
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet B"
  }
}

### PUBLIC SUBNET C ###
resource "aws_subnet" "public_subnet_c" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
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

### ENABLE OUTBOUND INTERNET ACCESS FOR PRIVATE SUBNETS ###
resource "aws_route" "private_internet_route" {
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.aws_nat_gateway_a.id
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

### CREATE THE EKS CLUSTER ###
resource "aws_eks_cluster" "my_eks_cluster" {
  name = "my_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
        aws_subnet.private_subnet_a.id,
        aws_subnet.private_subnet_b.id,
        aws_subnet.private_subnet_c.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

### EKS CLUSTER ROLE ###
### permissions for EKS Control Plane to manage AWS resources ###
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "eks.amazonaws.com" # EKS service is allowed to consume this role
            }
            Action = "sts:AssumeRole"
        }
    ]
  })
}

### EKS ROLE POLICY ATTACHMENT ###
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role = aws_iam_role.eks_cluster_role.name
  # Pre-defined AWS managed policy that grants EKS permissions for necessary cluster management.connection
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

### NODE GROUP IAM ROLE ###
# Node groups need IAM roles to interact with EKS control plane 

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })
}

### NODE ROLE POLICY ATTACHMENT ###
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

### ON DEMAND NODE GROUP ###
resource "aws_eks_node_group" "on_demand_node_group" {
  cluster_name = aws_eks_cluster.my_eks_cluster.name
  node_group_name = "on-demand-node-group"
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id,
    aws_subnet.private_subnet_c.id
  ]

  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 2
  }

  instance_types = ["t2.micro"]

  capacity_type = "ON_DEMAND"

  tags = {
    Name = "On-Demand Node Group"
  }
}

### SPOT NODE GROUP ###
resource "aws_eks_node_group" "spot_node_group" {
  cluster_name = aws_eks_cluster.my_eks_cluster.name
  node_group_name = "spot-node-group"
  node_role_arn =  aws_iam_role.eks_node_group_role.arn
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id,
    aws_subnet.private_subnet_c.id
  ]

  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 2
  }

  instance_types = ["t2.micro"]

  capacity_type = "SPOT"

  tags = {
    Name = "Spot Node Group"
  }
}











