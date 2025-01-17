data "aws_availability_zones" "available_azs" {
  state = "available"
}

/*data "aws_eks_cluster_auth" "my_eks_cluster_auth" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster" "my_eks_cluster" {
  name = var.eks_cluster_name
}

data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "terraform.tfstate"
  }
}*/

data "aws_subnet" "public_subnet_1" {
  filter {
    name   = "cidrBlock"
    values = ["10.0.1.0/24"]
  }
  depends_on = [module.vpc]
}

data "aws_subnet" "public_subnet_2" {
  filter {
    name   = "cidrBlock"
    values = ["10.0.2.0/24"]
  }
  depends_on = [module.vpc]
}

data "aws_subnet" "public_subnet_3" {
  filter {
    name   = "cidrBlock"
    values = ["10.0.3.0/24"]
  }
  depends_on = [module.vpc]
}

