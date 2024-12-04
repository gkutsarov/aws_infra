terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

provider "aws" {
  region = var.region
}

### CREATE PRIVATE ROUTE53 ZONE ###
resource "aws_route53_zone" "private_zone" {
  name = var.route53_private_zone
  vpc {
    vpc_id = module.vpc.vpc_id       # Use the VPC ID from the VPC module
  }

  comment = "Private Route 53 Zone for internal use."

  tags = {
    Name = var.tags
  }
}












