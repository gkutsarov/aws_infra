resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  
  version    = "1.9.2"
  
  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "image.tag"
    value = "v2.9.2"
  }
  set {
    name  = "replicaCount"
    value = 2
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_role.iam_role_arn
  }
  set {
    name  = "nodeSelector.type"
    value = "on_demand"
  }
  set {
    name  = "region"
    value = var.region
  }
  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
}