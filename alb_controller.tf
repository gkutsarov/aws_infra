resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "default"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  values = [
    <<EOF
clusterName: "${var.eks_cluster_name}"
region: "${var.region}"
vpcId: "${module.vpc.vpc_id}"
autoDiscoverAwsRegion: false
autoDiscoverAwsVpcID: false
EOF
  ]

  depends_on = [module.iam_eks_role]
}

/* need to have 
- service account
- cluster name
- namespace
- role-name
- policy attached 
