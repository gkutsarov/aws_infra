output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_ids" {
  value       = module.vpc.public_subnets
  description = "List of IDs for all public subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "List of IDs for all private subnets"
}

output "internet_gateway_id" {
  value = module.vpc.igw_id
}

output "nat_gateway_id" {
  value = module.vpc.nat_ids
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The endpoint for the EKS cluster API server"
}

output "eks_cluster_ca" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "eks_admin_role_arn" {
  value = aws_iam_role.eks_admin_role.arn
}

/*output "argocd_alb_dns_name" {
  value = data.external.argocd_alb_dns_name.result["hostname"]
  description = "The DNS name of the ALB created by ArgoCD."
}*/

/*output "auth_token" {
  value     = data.aws_eks_cluster_auth.auth.token
  sensitive = true
}*/

/*output "eks_coredns_version" {
  description = "Version of the CoreDNS addon"
  value       = "${data.aws_eks_addon_version.main["coredns"].version}"
}

output "eks_kube_proxy_version" {
  description = "Version of the kube-proxy addon"
  value       = "${data.aws_eks_addon_version.main["kube-proxy"].version}"
}

output "eks_vpc_cni_version" {
  description = "Version of the VPC CNI addon"
  value       = "${data.aws_eks_addon_version.main["vpc-cni"].version}" 
}

output "eks_pod_identity_agent_version" {
  description = "Version of the EKS pod identity agent addon"
  value       = "${data.aws_eks_addon_version.main["eks-pod-identity-agent"].version}"
}
*/
output "eks_node_group_ami_release_version" {
  description = "AMI release version for the EKS managed node group"
  // As there is no direct way to get the AMI release version for the EKS managed node group AMI
  // we are concatenating the k8s version from the AMI description and the release date from the AMI name
  // which actually provides the release version.
  // The AMI release versions can be found in the AWS AMI GitHub Changelog:
  // https://github.com/awslabs/amazon-eks-ami/blob/main/CHANGELOG.md
  value = "${regex("k8s: ([0-9.]+)", data.aws_ami.main.description)[0]}-${substr(data.aws_ami.main.name, length(data.aws_ami.main.name) - 8, 8)}"
}