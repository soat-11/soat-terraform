# AWS Infrastructure with Terraform

This repository contains Terraform configurations to provision and manage AWS infrastructure including EKS, RDS, VPC, and other related services.

## Project Structure

The project is organized in 3 independent layers with separate Terraform states:

```
soat-terraform/
├── cloud-base/          # Layer 1: AWS Cloud Infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── vpc/
│       ├── subnets/
│       ├── internet-gateway/
│       ├── route-table/
│       ├── security-group/
│       ├── container-registry/
│       ├── bucket/
│       ├── cognito/
│       └── lambda/
│
├── kubernetes/          # Layer 2: EKS Cluster
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── cluster/
│       ├── node/        # Uses Spot Instances for cost savings
│       └── metrics/
│
├── apps/                # Layer 3: Microservices
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── terraform.tfvars
│   ├── payment/         # Payment microservice
│   ├── cart/            # Cart microservice
│   ├── admin/           # Admin microservice
│   └── modules/
│       └── api-gateway/
│
└── shared-modules/      # Reusable K8s modules
    ├── deployment/
    ├── service/
    ├── ingress/
    ├── secrets/
    └── hpa/
```

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

### 2. S3 Backend Setup

Create a unique S3 bucket for storing Terraform state. The project uses 3 separate state files:
- `cloud-base/terraform.tfstate`
- `kubernetes/terraform.tfstate`
- `apps/terraform.tfstate`

### 3. Deploy Infrastructure (In Order)

**Layer 1: Cloud Base**
```bash
cd cloud-base
terraform init
terraform apply
```

**Layer 2: Kubernetes**
```bash
cd kubernetes
terraform init
terraform apply
```

**Layer 3: Applications**
```bash
cd apps
terraform init
terraform apply
```

### 4. Container Image Deployment

1. Navigate to AWS ECR (Elastic Container Registry)
2. Build container images for each microservice (payment, cart, admin)
3. Tag and push images to ECR
4. Update the image variables in `apps/terraform.tfvars`
5. Run Terraform apply:
```bash
cd apps
terraform apply
```


## Microservices Routes

- `/payment/*` - Payment service
- `/cart/*` - Cart service  
- `/admin/*` - Admin service
- `/signup` - Cognito signup (Lambda)
- `/login` - Cognito login (Lambda)
