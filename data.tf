data "aws_availability_zones" "available_azs" {
  state = "available"
}

data "aws_eks_cluster_auth" "auth" {
  name = var.eks_cluster_name
}