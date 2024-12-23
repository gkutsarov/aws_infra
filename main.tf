### CREATE PRIVATE ROUTE53 ZONE ###
resource "aws_route53_zone" "private_zone" {
  name = var.route53_private_zone
  vpc {
    vpc_id = module.vpc.vpc_id # Use the VPC ID from the VPC module
  }

  comment = "Private Route 53 Zone for internal use."

  tags = {
    Name = var.tags
  }
}

resource "aws_iam_user" "eks_admin" {
  name = "eks_admin"
}

resource "aws_iam_role" "eks_admin_role" {
  name = "eks_admin_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::905418146175:user/eks_admin"
          AWS = "arn:aws:iam::905418146175:user/iamadmin"
        }
      },
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "eks.amazonaws.com" }
      }
    ]
  })
}


/*
resource "kubernetes_service_account" "pod-service-account" {
  metadata {
    name = "pod-service-account"
    namespace = "default"
    labels = {
      "app.kubernetes.io/name" = "pod-service-account"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_eks_role.iam_role_arn
    }
  }
}

resource "kubernetes_service_account" "load-balancer-controller" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lb_role.iam_role_arn
    }
  }
}*/

















