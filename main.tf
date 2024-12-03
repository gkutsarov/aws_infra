terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

provider "aws" {
  region = var.region
}

# Create the VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc

  tags = {
    Name = var.tags
  }
}

### DEPLOY PUBLIC SUBNETS ###
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available_azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

### INTERNET GATEWAY ###
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.tags
  }
}

### PUBLIC ROUTE TABLE ***
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.tags
  }
}

### ENABLE INTERNET ACCESS ###
resource "aws_route" "public_internet_route" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_igw.id
}

### ROUTE TABLE SUBNET ASSOCIATION FOR PUBLIC SUBNETS ###
resource "aws_route_table_association" "public_subnet_association" {
  count = length(aws_subnet.public_subnet)
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

### CREATE ELASTIC IP FOR NAT GATEWAY ###
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

### CREATE NAT GATEWAY IN PUBLIC SUBNET ###
resource "aws_nat_gateway" "aws_nat_gateway" {
  allocation_id =  aws_eip.nat_eip.allocation_id  # Associate the NAT Gateway with the Elastic IP
  subnet_id = aws_subnet.public_subnet[0].id # Public Subnet A where the NAT Gateway will be created

  tags = {
    Name = var.tags
  }
  depends_on = [aws_internet_gateway.my_igw]
}

### DEPLOY PRIVATE SUBNETS ###
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available_azs.names[count.index]
  
  tags = {
    Name = "Private Subnet ${count.index + 1}"
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
  nat_gateway_id = aws_nat_gateway.aws_nat_gateway.id
}

### ROUTE TABLE ASSOCIATION FOR PRIVATE SUBNETS ###
resource "aws_route_table_association" "private_subnet_association" {
  count = length(aws_subnet.private_subnet)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

### CREATE PRIVATE ROUTE53 ZONE ###
resource "aws_route53_zone" "private_zone" {
  name = var.route53_private_zone
  vpc {
    vpc_id = aws_vpc.my_vpc.id # Associate the zone with the VPC
  }
}

### CREATE THE EKS CLUSTER ###
resource "aws_eks_cluster" "my_eks_cluster" {
  name = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.private_subnet[*].id  # Dynamically fetches all private subnet IDs
    endpoint_private_access = true                # Enable private API endpoint
    endpoint_public_access  = false               # Disable public API endpoint
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
  node_group_name = "on_demand_node_group"
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  subnet_ids = aws_subnet.private_subnet[*].id # Dynamically references all private subnets

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
  node_group_name = "spot_node_group"
  node_role_arn =  aws_iam_role.eks_node_group_role.arn
  subnet_ids = aws_subnet.private_subnet[*].id # Dynamically references all private subnets

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











