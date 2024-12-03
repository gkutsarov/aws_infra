output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnet[*].id
  description = "List of IDs for all public subnets"
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
  description = "List of IDs for all private subnets"
}

output "internet_gateway_id" {
    value = aws_internet_gateway.my_igw.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.aws_nat_gateway.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.my_eks_cluster.endpoint
  description = "The endpoint for the EKS cluster API server"
}