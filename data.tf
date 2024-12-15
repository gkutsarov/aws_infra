data "aws_availability_zones" "available_azs" {
  state = "available"
}

data "aws_eks_cluster_auth" "auth" {
  name = var.eks_cluster_name
}

data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "terraform.tfstate"
  }
}