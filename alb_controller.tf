resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [kubernetes_service_account.load-balancer-controller]

  set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  values = [
    <<EOF
clusterName: "${var.eks_cluster_name}"
region: "${var.region}"
vpcId: "${module.vpc.vpc_id}"
EOF
]

  
}
