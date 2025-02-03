### CREATE PRIVATE ROUTE53 ZONE ###
resource "aws_route53_zone" "private_zone" {
  name = var.route53_private_zone
  vpc {
    vpc_id = module.vpc.vpc_id # Use the VPC ID from the VPC module
  }

  comment = "Private Route 53 Zone for internal use."

  tags = var.tags
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

## Create the AWS Secret
resource "aws_secretsmanager_secret" "github_token" {
  name = "github-argo"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "github_token" {
  secret_id = aws_secretsmanager_secret.github_token.id
  secret_string = jsonencode({
    username = var.github_username
    token = var.github_pat
  })
}

resource "kubernetes_namespace" "name" {
  metadata {
    annotations = {
      name = "argocd"
    }
    name = "argocd"
  }
}

## Create k8s secret from the stored secret in AWS. Which we will pass to our ArgoCD
resource "kubernetes_secret" "argocd_repo_secret" {
  metadata {
    name = "github-argo"
    namespace = "argocd"
  }

  data = {
    username = (jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["username"])
    token    = (jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["token"])
  } 
}






















