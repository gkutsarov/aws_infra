# AWS + EKS + VPC + IAM Roles + Secret Manager + ALB + SA + ArgoCD + Terraform

# Project Overview

This project demonstrates deploying an AWS EKS cluster with 2 node groups (on demand and spot), a VPC, IAM roles, Application Load Balancer, service accounts and ArgoCD. All deployed with IaC using Terraform. 

# Key Features:

- **AWS EKS**: The infrastructure of which our project builds on.
- **AWS VPC**: The networking environment where our EKS cluster run. Public and Private subnets, NAT Gateway for Private subnets.
- **IAM Roles**: The Roles + policies which are needed for service accounts to access different AWS resources. (S3 for example)
- **Secret Manager**: For storing and fetching secrets securely for our infrastructure/service accounts.
- **ALB**: Deploys ALB Controller in our EKS.
- **SA**: Service Accounts + needed roles and policies which they need to perform certain actions.
- **ArgoCD**: GitOps CD tool which streamlines the process of deploying applications on our cluster.

# Project Structure

Here’s a breakdown of the key files in this repository:

- **alb_controller.tf**: Deploys the AWS ALB with our custom EKS values.
- **argocd.tf**: Deploys ArgoCD, configures a github repository in ArgoCD and deploys initial App of Apps app using the configured repo.
- **data.tf**: Data block used during the provision of the infrastructure.
- **eks.tf**: Deploys the EKS, cluster addons, node groups, IAM Roles.
- **main.tf**: Route53, IAM user, K8S resources, secrets and policies.
- **terraform.tf**: Defines the providers with which our terraform code interact with. AWS/K8S/Helm
- **values.yaml.tpl**: Values file as a template used for ArgoCD. Used for dynamically pass the usernamer + password for the GitHub repository.
- **variables.yaml**: Variables used for our infrastructure.

