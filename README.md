# AWS Infrastructure with Terraform

This repository contains Terraform configurations to provision and manage AWS infrastructure including EKS, RDS, VPC, and other related services.

## Prerequisites

- AWS Academy account
- AWS CLI installed and configured
- Terraform installed
- Docker installed (for building and pushing container images)
- Access to the soat-architecture application repository

## Getting Started

### 1. AWS Credentials Setup

```bash
# Add your AWS Academy credentials to AWS CLI configuration
aws configure --profile soat
```
2. S3 Backend Setup
Create a unique S3 bucket for storing Terraform state
Update the bucket name in ```backend.tf```:
```
terraform {
  backend "s3" {
    bucket  = "your-unique-bucket-name"
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-1"
    profile = "soat"
  }
}
```
3. Initialize and Apply Terraform
```bash
# Initialize Terraform
terraform init

# Apply the infrastructure changes
terraform apply
```

4. Container Image Deployment
    1. Navigate to AWS ECR (Elastic Container Registry)
    2. Build a new container image from the soat-architecture project
    3. Tag and push the image to ECR
    4. Run Terraform apply again to update the deployment:
```bash
terraform apply
```

## Infrastructure Components
- VPC with public and private subnets
- EKS cluster for Kubernetes workloads
- RDS database instance
- ECR repository for container images
- Security groups and IAM roles
- Load balancers and ingress controllers

## Important Notes
- Make sure to review the Terraform plan before applying changes
- The infrastructure is designed to work in the us-east-1 region by default
- Remember to destroy resources when they're no longer needed to avoid unnecessary costs