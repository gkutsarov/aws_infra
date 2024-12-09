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

resource "aws_iam_role" "eks_admin" {
  name = "eks_admin_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = { Service = "eks.amazonaws.com"}
            Action = "sts:AssumeRole"
        },
        {
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::905418146175:user/iamadmin"}
            Action = "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_policy_attachment" "eks_admin_policy" {
  name = "eks_admin_policy_attachment"
  roles = [aws_iam_role.eks_admin.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}












