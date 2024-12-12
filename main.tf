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
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_user.eks_admin.arn
        }
      }
    ]
  })
}













