module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20" # Use the latest possible version

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["77.70.78.206/32"]
  authentication_mode                  = "API"
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
      #addon_version = var.eks_coredns_version
      ##resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
    eks-pod-identity-agent = {
      #addon_version = var.eks_pod_identity_agent_version
      ##resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
    kube-proxy = {
      #addon_version = var.eks_kube_proxy_version
      ##resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
    vpc-cni = {
      #addon_version            = var.eks_vpc_cni_version
      #service_account_role_arn = module.cni_irsa_role.iam_role_arn
      ##resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
    # Enables Kubernetes to dynamically provision and manage EBS volumes as persistent storage for applications. We use this to provision the node volumes for Loki.
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
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
      name          = var.eks_on_demand_group
      cluster_name  = var.eks_cluster_name
      subnet_ids    = module.vpc.private_subnets
      ami_type      = "AL2023_x86_64_STANDARD"
      min_size      = var.eks_on_demand_min_size
      max_size      = var.eks_on_demand_max_size
      desired_size  = var.eks_on_demand_desired_size
      capacity_type = var.eks_on_demand_type
      ebs_optimized = true
      instance_types = ["t2.large"]
      labels = {
        environment = "production"
        type        = "on_demand"
      }
    }

    spot = {
      name          = var.eks_spot_group
      cluster_name  = var.eks_cluster_name
      subnet_ids    = module.vpc.private_subnets
      ami_type      = "AL2023_x86_64_STANDARD"
      min_size      = var.eks_spot_min_size
      max_size      = var.eks_spot_max_size
      desired_size  = var.eks_spot_desired_size
      capacity_type = var.eks_spot_type
      ebs_optimized = true
      instance_types = ["t2.large"]
      labels = {
        environment = "development"
        type        = "spot"
      }
    }
  }
  tags = var.tags
}

/*data "aws_eks_addon_version" "main" {
  for_each = toset(["coredns", "kube-proxy", "vpc-cni", "eks-pod-identity-agent"])

  addon_name         = each.value
  kubernetes_version = var.eks_cluster_version
  // Setting this to `true` will use the latest addons version for the specified cluster version
  // Setting this to `false` will use the recommended addons version for the specified cluster version
  most_recent = true
}
*/

data "aws_ssm_parameter" "main" {
  // The following request is for the AL2023_x86_64_STANDARD ami type set as default in the EKS managed node group
  // If you change the ami type, you should update the filter values accordingly:
  // https://docs.aws.amazon.com/eks/latest/userguide/retrieve-ami-id.html
  name = "/aws/service/eks/optimized-ami/${var.eks_cluster_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

data "aws_ami" "main" {
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.main.value]
  }

  most_recent = true
  // Amazon EKS AMI Account ID
  owners = ["602401143452"]
}


module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "loki-service-account-role"

  role_policy_arns = {
    policy = aws_iam_policy.loki_s3_policy.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["loki:loki"]
    }
  }
}

module "cloudwatch_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "prometheus-cloudwatch-exporter-role"

  role_policy_arns = {
    policy = aws_iam_policy.cloudwatch_exporter_policy.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["prometheus:prometheus-cloudwatch-exporter-sa"]
    }
  }
}

module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "load-balancer-role"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

module "cni_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "vpc-cni-irsa-role"

  attach_vpc_cni_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:vpc_cni_service_account_custom"]
    }
  }
}

module "ebs_csi_irsa_role" {
	source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

	role_name             = "${var.eks_cluster_name}-ebs-csi"
	attach_ebs_csi_policy = true

	oidc_providers = {
		ex = {
			provider_arn               = module.eks.oidc_provider_arn
			namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
		}
	}
}





