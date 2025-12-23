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
├── shared-modules/      # Reusable K8s modules
│   ├── deployment/
│   ├── service/
│   ├── ingress/
│   ├── secrets/
│   └── hpa/
│
└── local/               # Local testing environment
    ├── docker-compose.yml
    ├── setup.sh
    ├── teardown.sh
    ├── cloud-base-local/
    └── apps-local/
```

## Prerequisites

- AWS Academy account (for production deployment)
- AWS CLI installed and configured
- Terraform installed
- Docker installed
- kubectl installed

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

## Infrastructure Components

### Cloud Base Layer
- VPC with public subnets
- Internet Gateway and Route Tables
- Security Groups
- ECR repository for container images
- S3 Bucket for orders
- Cognito User Pool for authentication
- Lambda functions (signup/login)

### Kubernetes Layer
- EKS cluster
- Node Group with **Spot Instances** (t3.small/t3a.small) - ~80% cost savings
- Metrics Server for HPA

### Apps Layer
- 3 Microservices: Payment, Cart, Admin
- Each with: Deployment, Service, Ingress, Secrets, HPA
- API Gateway for routing
- Nginx Ingress Controller

## Cost Optimizations

| Resource | Configuration | Savings |
|----------|--------------|---------|
| Node Group | Spot Instances (t3.small/t3a.small) | ~80% |
| Deployments | CPU: 100m-250m, Memory: 256Mi-512Mi | More pods per node |
| HPA | Auto-scaling 1-2 replicas | Pay for what you use |

## Microservices Routes

- `/payment/*` - Payment service
- `/cart/*` - Cart service  
- `/admin/*` - Admin service
- `/signup` - Cognito signup (Lambda)
- `/login` - Cognito login (Lambda)

---

## Local Testing

You can test the infrastructure locally using **LocalStack** (AWS simulation) and **Kind** (Kubernetes simulation).

### Prerequisites for Local Testing

```bash
# macOS
brew install docker terraform kubectl kind

# Linux
# Install Docker, Terraform, kubectl, and Kind from their official sources
```

### Quick Start

#### 1. Start Local Environment

```bash
cd local
./setup.sh
```

This will:
- Start **LocalStack** container (simulates AWS services on port 4566)
- Create **Kind** cluster (local Kubernetes)
- Install NGINX Ingress Controller
- Create S3 bucket for Terraform state

#### 2. Test Cloud Base (AWS Services)

```bash
cd local/cloud-base-local
terraform init
terraform apply -auto-approve
```

This tests:
- S3 Buckets
- Lambda Functions
- API Gateway
- Cognito User Pool
- ECR Repository
- SSM Parameters

#### 3. Test Apps (Kubernetes)

```bash
cd local/apps-local
terraform init
terraform apply -auto-approve
```

This deploys to the Kind cluster:
- Payment, Cart, Admin deployments
- Services and Ingress
- Secrets

#### Loading Custom Images to Kind

To use your own container images instead of the default `nginx:alpine`:

**Build your images locally:**

```bash
docker build -t payment:latest ./path/to/payment-service
docker build -t cart:latest ./path/to/cart-service
docker build -t admin:latest ./path/to/admin-service
```

**Load images into Kind:**

```bash
kind load docker-image payment:latest --name soat-local
kind load docker-image cart:latest --name soat-local
kind load docker-image admin:latest --name soat-local
```

**Update variables in `local/apps-local/variables.tf`:**

```hcl
variable "payment_image" {
  default = "payment:latest"
}

variable "cart_image" {
  default = "cart:latest"
}

variable "admin_image" {
  default = "admin:latest"
}
```

**Apply Terraform:**

```bash
cd local/apps-local
terraform apply -auto-approve
```

**Quick test with nginx (if you don't have images ready):**

```bash
# Create simple test images
echo 'FROM nginx:alpine' | docker build -t payment:latest -
echo 'FROM nginx:alpine' | docker build -t cart:latest -
echo 'FROM nginx:alpine' | docker build -t admin:latest -

# Load into Kind
kind load docker-image payment:latest --name soat-local
kind load docker-image cart:latest --name soat-local
kind load docker-image admin:latest --name soat-local
```

#### 4. Verify Resources

```bash
# Check LocalStack (AWS)
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 lambda list-functions
aws --endpoint-url=http://localhost:4566 cognito-idp list-user-pools --max-results 10

# Check Kind (Kubernetes)
kubectl get pods
kubectl get svc
kubectl get ingress
```

#### 5. Test Endpoints

```bash
# Kubernetes services (via Ingress)
curl http://localhost/payment/
curl http://localhost/cart/
curl http://localhost/admin/

# API Gateway (LocalStack)
curl http://localhost:4566/restapis
```

#### 6. Add Local Database (Optional)

If you need a PostgreSQL database for testing:

```bash
docker run -d \
  --name postgres-local \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=localpassword \
  -e POSTGRES_DB=soat_db \
  -p 5432:5432 \
  postgres:15-alpine
```

#### 7. Cleanup

```bash
cd local
./teardown.sh
```

Or manually:

```bash
# Destroy Terraform resources
cd local/apps-local && terraform destroy -auto-approve
cd ../cloud-base-local && terraform destroy -auto-approve

# Stop containers
cd .. && docker-compose down -v

# Delete Kind cluster
kind delete cluster --name soat-local

# Stop PostgreSQL (if running)
docker stop postgres-local && docker rm postgres-local
```

### LocalStack Limitations

| Service | Free Version | Alternative |
|---------|--------------|-------------|
| VPC | Not supported | Not needed locally |
| EKS | Pro only ($) | Kind/Minikube |
| RDS | Pro only ($) | PostgreSQL Docker |
| S3 | Works | - |
| Lambda | Works | - |
| API Gateway | Works | - |
| ECR | Works | - |
| Cognito | Partial | - |

---

## Destroy Infrastructure

Always destroy in **reverse order** to avoid dependency issues:

```bash
cd apps && terraform destroy
cd kubernetes && terraform destroy
cd cloud-base && terraform destroy
```

## Important Notes

- Make sure to review the Terraform plan before applying changes
- The infrastructure is designed to work in the us-east-1 region by default
- Remember to destroy resources when they're no longer needed to avoid unnecessary costs
- Local testing is free and doesn't require AWS credentials
