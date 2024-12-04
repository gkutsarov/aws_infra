module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20" # Use the latest possible version

  cluster_name = var.eks_cluster_name
  cluster_version = "1.31"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = false

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id = module.vpc.vpc_id 
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_service_ipv4_cidr = var.cluster_service_cidr

  tags = {
    Name = var.tags
  }
}

module "eks_node_group_on_demand" {
  source              = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  name                = var.node_group_name
  cluster_name        = var.eks_cluster_name
  subnet_ids          = module.vpc.private_subnets
  ami_type            = "AL2_x86_64"
  instance_types      = ["t2.micro"]
  min_size            = 1
  max_size            = 2
  desired_size        = 1
  capacity_type       = "ON_DEMAND"
  cluster_service_ipv4_cidr = var.cluster_service_cidr

  tags = {
    Environment = var.type_on_demand
  }
}

module "eks_node_group_spot" {
  source              = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  name                = var.node_group_name
  cluster_name        = var.eks_cluster_name
  subnet_ids          = module.vpc.private_subnets
  ami_type            = "AL2_x86_64"
  instance_types      = ["t2.micro"]
  min_size            = 1
  max_size            = 2
  desired_size        = 1
  capacity_type       = "SPOT"
  cluster_service_ipv4_cidr = var.cluster_service_cidr

  tags = {
    Environment = var.type_spot
  }
}

