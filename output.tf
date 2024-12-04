output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_ids" {
  value = module.vpc.public_subnets
  description = "List of IDs for all public subnets"
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
  description = "List of IDs for all private subnets"
}

output "internet_gateway_id" {
    value = module.vpc.igw_id
}

output "nat_gateway_id" {
  value = module.vpc.nat_ids
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "The endpoint for the EKS cluster API server"
}

output "private_subnets" {
  value = module.vpc.private_subnets
}