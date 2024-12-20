output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_ids" {
  value       = module.vpc.public_subnets
  description = "List of IDs for all public subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "List of IDs for all private subnets"
}

output "internet_gateway_id" {
  value = module.vpc.igw_id
}

output "nat_gateway_id" {
  value = module.vpc.nat_ids
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The endpoint for the EKS cluster API server"
}

output "eks_cluster_ca" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "eks_admin_role_arn" {
  value = aws_iam_role.eks_admin_role.arn
}

output "auth_token" {
  value     = data.aws_eks_cluster_auth.auth.token
  sensitive = true
}



