data "aws_availability_zones" "available_azs" {
  state = "available"
}

data "aws_eks_cluster_auth" "auth" {
  name = module.eks.cluster_name
}

/*data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "terraform.tfstate"
  }
}*/