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

## Create namespace argocd for ArgoCD
resource "kubernetes_namespace" "argocd_namespace" {
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

## LOKI S3s and policies from here
resource "random_string" "suffix" {
  length = 6
  special = false
  upper = false
}

resource "aws_s3_bucket" "loki_logs_bucket" {
  bucket = "loki-log-chunks-${random_string.suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket" "loki_alert_rules_bucket" {
  bucket = "loki-alert-rules-${random_string.suffix.result}"
  force_destroy = true
}


resource "aws_iam_policy" "loki_s3_policy" {
  name = "LokiS3AccessPolicy"
  description = "Policy for Loki to access S3 buckets for logs and alert rules."
  policy = data.aws_iam_policy_document.loki_policy.json
}

resource "kubernetes_namespace" "loki" {
  metadata {
    annotations = {
      name = "loki"
    }
    name = "loki"
  }
}

resource "kubernetes_secret" "loki_auth" { 
  metadata {
    name      = "loki-auth" 
    namespace = "loki" 
  }

  data = {
    username = (jsondecode(data.aws_secretsmanager_secret_version.loki_auth.secret_string)["username"]) 
    password = (jsondecode(data.aws_secretsmanager_secret_version.loki_auth.secret_string)["password"]) 
  } 
}

resource "kubernetes_secret" "canary_loki_auth" { 
  metadata {
    name      = "canary-loki-auth" 
    namespace = "loki" 
  }

  data = {
    username = (jsondecode(data.aws_secretsmanager_secret_version.canary_loki_auth.secret_string)["username"]) 
    password = (jsondecode(data.aws_secretsmanager_secret_version.canary_loki_auth.secret_string)["password"]) 
  } 
}






























