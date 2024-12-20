variable "vpc_name" {
  description = "Variable name for the created VPC"
  default     = "AWS Module VPC"
}

variable "tags" {
  description = "Tags for all the resources provisioned."
  default     = "AWS_INFRA_TF"
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "vpc" {
  description = "Custom VPC CIDR where we deploy our resources in"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "route53_private_zone" {
  description = "Name of the Route53 Private Zone"
  type        = string
  default     = "internal.zone.com"
}

variable "eks_cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
  default     = "my_eks_cluster"
}

variable "cluster_service_cidr" {
  description = "The CIDR block for the K8S service network"
  type        = string
  default     = "10.10.0.0/16"
}

variable "on_demand_group" {
  type    = string
  default = "on_demand_group"
}

variable "spot_group" {
  type    = string
  default = "spot_group"
}

variable "type_on_demand" {
  type    = string
  default = "ON_DEMAND"
}

variable "type_spot" {
  type    = string
  default = "SPOT"
}

variable "min_size" {
  type    = string
  default = "1"
}

variable "max_size" {
  type    = string
  default = "2"
}

variable "desired_size" {
  type    = string
  default = "1"
}
