resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  


#to check if service account create set to true and in main the resource on line 56 is commented - does the service account get created with the correct annotation
  /*set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }*/

  values = [
    <<EOF
clusterName: "${var.eks_cluster_name}"
region: "${var.region}"
vpcId: "${module.vpc.vpc_id}"
serviceAccount:
  name: aws-load-balancer-controller
  annotations: 
    eks.amazonaws.com/role-arn: "${module.lb_role.iam_role_arn}"
EOF
]

  
}
