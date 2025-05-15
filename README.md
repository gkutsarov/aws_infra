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

- **main.tf**
    - Creates AWS IAM users, Route53 DNS zone and core Kubernetes resources.
    - Manages AWS Secrets Manager entries.
    - Includes K8s RBAC and resource entries.
- **eks.tf**
    - Provisions EKS cluster with cluster-level settings
    - Configures managed node groups: **ON DEMAND** and **SPOT**
    - Defines cluster add-ons: coredns, **kube-proxy, vpc-cni, aws-ebs-csi-driver**
    - IRSA roles for:
        - Loki (S3 Access)
        - Prometheus (CloudWatch access)
        - ALB Controller
        - VPC CNI
        - EBS CSI Driver
    - Dynamically fetches AMI with SSM
- **vpc.tf**
    - Creates VPC, public & private subnets, route tables, internet & NAT gateway.
    - The subnet IDs are referenced in eks.tf for node placement.
- **alb_controller.tf**
    - Deploys ALB Ingress Controller via Helm with custom values.
    - Binds aws-load-balancer-controller service account to IAM role with necessary permissions.
- **argocd.tf** 
    - Installs ArgoCD into the cluster via Helm
    - Configures repository credentials.
    - Bootstrap initial App of Apps ArgoCD deployment.
- **data.tf**
    - Contains data sources:
        - AWS region, AZs
        - AMIs
        - VPC configuration
- **terraform.tf**
    - Provider configuration for: AWS, Kubernetes, Helm
    - Ensures Terraform can communicate with all required APIs
- **values.yaml.tpl**
    - Values file as a template used for ArgoCD. Used for dynamically pass the username + password for the GitHub repository.
- **variables.tf**
    - Declares variables used accross modules
    

