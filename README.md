# AWS Infrastructure with Terraform: Full Documentation

# :blue_book: Overview

This repository provisions a complete AWS infrastructure using Terraform. It is designed for deploying a secure and scalable Kubernetes platform with GitOps using ArgoCD. The stack includes EKS, VPC, IAM roles, service accounts, load balancing and secret management.

# :wrench: Key Features:

- **AWS EKS**: Managed Kubernetes cluster with two auto-scaling node groups.
- **AWS VPC**: The networking environment where our EKS cluster run. Public and Private subnets, NAT Gateway for Private subnets.
- **AWS IAM Roles**: The Roles + policies which are needed for service accounts to access different AWS resources. (S3 for example)
- **AWS Secret Manager**: For storing and fetching secrets securely for our infrastructure/service accounts.
- **ALB**: Deploys ALB Controller in our EKS.
- **SA**: Service Accounts + needed roles and policies which they need to perform certain actions.
- **ArgoCD**: GitOps CD tool which streamlines the process of deploying applications on our cluster.

# Project Structure

Here’s a breakdown of the key files in this repository:

- **alb_controller.tf**: Deploys the AWS ALB with our custom EKS values.
- **argocd.tf**: Deploys ArgoCD, configures a github repository in ArgoCD and deploys initial App of Apps app using the configured repo.
- **data.tf**: Data block used during the provision of the infrastructure.
- **eks.tf**: Deploys the EKS, cluster addons, node groups, IAM Roles.
- **main.tf**
    - Creates AWS IAM users, Route53 DNS zone and core Kubernetes resources.
    - Manages AWS Secrets Manager entries.
    - Includes K8s RBAC and resource entries.
- **terraform.tf**: Defines the providers with which our terraform code interact with. AWS/K8S/Helm
- **values.yaml.tpl**: Values file as a template used for ArgoCD. Used for dynamically pass the usernamer + password for the GitHub repository.
- **variables.yaml**: Variables used for our infrastructure.

