module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc

  azs             = data.aws_availability_zones.available_azs.names
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.tags
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/my_eks_cluster" = "shared"
  }
}