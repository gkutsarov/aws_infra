data "aws_availability_zones" "available_azs" {
  state = "available"
}

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

data "aws_secretsmanager_secret" "github_token" {
  name = "github_token"
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

data "aws_secretsmanager_secret" "loki_auth" {
  name = "loki_auth"
}

data "aws_secretsmanager_secret_version" "loki_auth" {
  secret_id = data.aws_secretsmanager_secret.loki_auth.id
}

## LOKI S3 BUCKET POLICY
data "aws_iam_policy_document" "loki_policy" {
   statement {
     sid = "LokiStorage"
     effect = "Allow"

     actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
     ]

     resources = [
      aws_s3_bucket.loki_logs_bucket.arn,
      "${aws_s3_bucket.loki_logs_bucket.arn}/*",
      aws_s3_bucket.loki_alert_rules_bucket.arn,
      "${aws_s3_bucket.loki_alert_rules_bucket.arn}/*"
     ]
   }
}




