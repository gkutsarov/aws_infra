variable "vpc_name" {
  description = "Variable name for the created VPC"
  default     = "AWS Module VPC"
}

variable "tags" {
  description = "Tags for all the resources provisioned."
  type        = map(string)
  default = {
    "Environment" = "Development"
    "Owner"       = "Grozdimir"
    "Project"     = "MyAWSProject"
  }
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

variable "cluster_service_cidr" {
  description = "The CIDR block for the K8S service network"
  type        = string
  default     = "10.10.0.0/16"
}

variable "eks_cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
  default     = "my_eks_cluster"
}

variable "eks_cluster_version" {
  type        = string
  description = "EKS cluster version."
  default     = "1.31"
}

variable "eks_coredns_version" {
  type        = string
  description = "CoreDNS version."
  default     = "v1.11.4-eksbuild.2"
}

variable "eks_kube_proxy_version" {
  type        = string
  description = "Kube proxy version."
  default     = "v1.31.3-eksbuild.2"
}

variable "eks_vpc_cni_version" {
  type        = string
  description = "VPC CNI version."
  default     = "v1.19.0-eksbuild.1"
}

variable "eks_pod_identity_agent_version" {
  type        = string
  description = "EKS pod identity agent version."
  default     = "v1.3.4-eksbuild.1"
}

variable "eks_on_demand_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "eks_on_demand_min_size" {
  type    = string
  default = "1"
}

variable "eks_on_demand_max_size" {
  type    = string
  default = "1"
}

variable "eks_on_demand_desired_size" {
  type    = string
  default = "1"
}

variable "eks_on_demand_group" {
  type    = string
  default = "on_demand_group"
}

variable "eks_spot_type" {
  type    = string
  default = "SPOT"
}

variable "eks_spot_min_size" {
  type    = string
  default = "1"
}

variable "eks_spot_max_size" {
  type    = string
  default = "2"
}

variable "eks_spot_desired_size" {
  type    = string
  default = "1"
}

variable "eks_spot_group" {
  type    = string
  default = "spot_group"
}

variable "github_username" {
  description = "GitHub username"
  sensitive = true
}

variable "github_pat" {
  description = "Github PAT"
  sensitive = true
}