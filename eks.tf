module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20" # Use the latest possible version

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.31"

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["77.70.78.206/32"]
  authentication_mode = "API"

  access_entries = {
    eks_admin = {
      principal_arn = aws_iam_role.eks_admin_role.arn

      policy_associations = {
        eks_admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
        eks_cluster_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
      ##resolve_conflicts = "OVERWRITE"
    }
    eks-pod-identity-agent = {
      ##resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
    kube-proxy = {
      ##resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
    vpc-cni = {
      ##resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_service_ipv4_cidr = var.cluster_service_cidr

  enable_irsa = true

  eks_managed_node_group_defaults = {
    instance_types = ["t2.medium", "t2.large", "t2.xlarge"]
  }

  eks_managed_node_groups = {
    on_demand = {
      name                      = var.on_demand_group
      cluster_name              = var.eks_cluster_name
      subnet_ids                = module.vpc.private_subnets
      ami_type                  = "AL2_x86_64"
      min_size                  = var.min_size
      max_size                  = var.max_size
      desired_size              = var.desired_size
      capacity_type             = "ON_DEMAND"
      cluster_service_ipv4_cidr = var.cluster_service_cidr

      labels = {
        environment = "production"
        type = "on_demand"
      }
    }
    spot = {
      name                      = var.spot_group
      cluster_name              = var.eks_cluster_name
      subnet_ids                = module.vpc.private_subnets
      ami_type                  = "AL2_x86_64"
      min_size                  = var.min_size
      max_size                  = var.max_size
      desired_size              = var.desired_size
      capacity_type             = "ON_DEMAND"
      cluster_service_ipv4_cidr = var.cluster_service_cidr

      labels = {
        environment = "development"
        type = "spot"
      }
    }
  }
  tags = {
    Name = var.tags
  }
}

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "pod_service_account"

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:pod_service_account"]
    }
  }
}


