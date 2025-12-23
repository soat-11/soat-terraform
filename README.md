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

Teste a infraestrutura localmente usando **LocalStack** (AWS) + **Kind** (Kubernetes).

### Arquitetura Local

```
┌─────────────────────────────────────────────────────────────────┐
│                    local/apps-local/                             │
│         Reutiliza módulos de apps/ (mesma config de prod)       │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ module "payment" { source = "../../apps/payment" }          ││
│  │ module "cart"    { source = "../../apps/cart" }             ││
│  │ module "admin"   { source = "../../apps/admin" }            ││
│  │                                                              ││
│  │ Sobrescreve apenas:                                          ││
│  │ - image: imagem local                                        ││
│  │ - ingress_host: localhost                                    ││
│  │ - cpu/memory: recursos menores                               ││
│  │ - vars: endpoints locais (LocalStack, MongoDB, etc)          ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
    ┌──────────┐         ┌──────────┐        ┌──────────┐
    │   Kind   │         │LocalStack│        │  Docker  │
    │   K8s    │◄───────►│   AWS    │        │ MongoDB  │
    │:80/:443  │         │  :4566   │        │ :27017   │
    └──────────┘         └──────────┘        └──────────┘
```

### Pré-requisitos

```bash
# macOS
brew install docker terraform kubectl kind

# Linux
# Instale Docker, Terraform, kubectl e Kind
```

### Quick Start

### Create terraform.tfvars
folder => apps
```
payment_vars = {
  MERCADO_PAGO_POS_ID                            = ""
  MERCADO_PAGO_API_URL                           = "https://api.mercadopago.com/"
  MERCADO_PAGO_PAYMENT_ACCESS_TOKEN              = ""
  MERCADO_PAGO_WEBHOOK_SECRET_KEY                = ""
  NODE_ENV                                       = "development"
  PORT                                           = 3010
  MONGODB_URI                                    = "mongodb://admin:localpassword@host.docker.internal:27017/payment?authSource=admin"
  AWS_REGION                                     = "us-east-1"
  AWS_ENDPOINT                                   = "http://host.docker.internal:4566"
  AWS_ACCESS_KEY_ID                              = "test"
  AWS_SECRET_ACCESS_KEY                          = "test"
  AWS_SQS_CREATE_PAYMENT_QUEUE_URL               = "http://host.docker.internal:4566/000000000000/create-payment-queue"
  AWS_SQS_PAYMENT_PAID_QUEUE_URL                 = "http://host.docker.internal:4566/000000000000/payment-paid-queue"
  AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL = "http://host.docker.internal:4566/000000000000/mercado-pago-process-payment-queue"
  AWS_SQS_CANCEL_PAYMENT_QUEUE_URL               = "http://host.docker.internal:4566/000000000000/cancel-payment-queue"
  db_host                                        = "host.docker.internal"

}
```

folder app-locals

```
payment_vars = {
  MERCADO_PAGO_POS_ID                            = ""
  MERCADO_PAGO_API_URL                           = "https://api.mercadopago.com/"
  MERCADO_PAGO_PAYMENT_ACCESS_TOKEN              = ""
  MERCADO_PAGO_WEBHOOK_SECRET_KEY                = ""
  NODE_ENV                                       = "development"
  PORT                                           = 3010
  MONGODB_URI                                    = "mongodb://admin:localpassword@host.docker.internal:27017/payment?authSource=admin"
  AWS_REGION                                     = "us-east-1"
  AWS_ENDPOINT                                   = "http://host.docker.internal:4566"
  AWS_ACCESS_KEY_ID                              = "test"
  AWS_SECRET_ACCESS_KEY                          = "test"
  AWS_SQS_CREATE_PAYMENT_QUEUE_URL               = "http://host.docker.internal:4566/000000000000/create-payment-queue"
  AWS_SQS_PAYMENT_PAID_QUEUE_URL                 = "http://host.docker.internal:4566/000000000000/payment-paid-queue"
  AWS_SQS_MERCADO_PAGO_PROCESS_PAYMENT_QUEUE_URL = "http://host.docker.internal:4566/000000000000/mercado-pago-process-payment-queue"
  AWS_SQS_CANCEL_PAYMENT_QUEUE_URL               = "http://host.docker.internal:4566/000000000000/cancel-payment-queue"
  db_host                                        = "host.docker.internal"

}
```

folder cloud-base

```
project = "soat-challenge"
region  = "us-east-1"
```

#### 1. Iniciar ambiente local

```bash
cd local
./setup.sh
```

Isso irá:
- Iniciar **LocalStack** (AWS na porta 4566)
- Iniciar **MongoDB** e **PostgreSQL** (Docker)
- Criar cluster **Kind** (Kubernetes local)
- Instalar NGINX Ingress Controller

#### 2. Aplicar infraestrutura AWS (LocalStack)

```bash
cd local/cloud-base-local
terraform init
terraform apply -auto-approve
```

#### 3. Aplicar microserviços (Kind)

```bash
cd local/apps-local
terraform init
terraform apply -auto-approve
```

O `apps-local` **reutiliza os mesmos módulos de produção** (`apps/payment`, `apps/cart`, `apps/admin`), apenas sobrescrevendo variáveis para o ambiente local.

### Usando imagens customizadas

#### Build da imagem (arquitetura correta para Mac M1/M2)

```bash
# IMPORTANTE: Se você usa Mac com Apple Silicon, build para a arquitetura correta
docker build --platform linux/arm64 -t soat-payment:latest ./path/to/payment
docker build --platform linux/arm64 -t soat-cart:latest ./path/to/cart
docker build --platform linux/arm64 -t soat-admin:latest ./path/to/admin
```

#### Carregar imagens no Kind

```bash
kind load docker-image soat-payment:latest --name soat-local
kind load docker-image soat-cart:latest --name soat-local
kind load docker-image soat-admin:latest --name soat-local
```

#### Verificar se carregou

```bash
docker exec soat-local-worker crictl images | grep soat
```

#### Aplicar

```bash
cd local/apps-local
terraform apply -auto-approve
```

### Sobrescrever variáveis locais

Crie `local/apps-local/terraform.tfvars`:

```hcl
# Imagens
payment_image = "soat-payment:latest"
cart_image    = "soat-cart:latest"
admin_image   = "soat-admin:latest"

# Mercado Pago (opcional)
mercado_pago_pos_id               = "seu-pos-id"
mercado_pago_payment_access_token = "seu-token"
mercado_pago_webhook_secret_key   = "seu-webhook-secret"
```

### Verificar recursos

```bash
# Kubernetes
kubectl get pods
kubectl get svc
kubectl get ingress

# SQS (LocalStack)
aws --endpoint-url=http://localhost:4566 sqs list-queues

# Logs de um pod
kubectl logs -f deployment/payment-deployment
```

### Testar endpoints

```bash
# Via Ingress
curl http://localhost/payment/health
curl http://localhost/cart/health
curl http://localhost/admin/health

# Acessar um pod diretamente
kubectl port-forward deployment/payment-deployment 3010:3010
curl http://localhost:3010/health
```

### Debuggar problemas

```bash
# Ver eventos do pod
kubectl describe pod -l app=payment

# Verificar conectividade com MongoDB
kubectl exec -it deployment/payment-deployment -- nc -zv host.docker.internal 27017

# Verificar conectividade com LocalStack
kubectl exec -it deployment/payment-deployment -- nc -zv host.docker.internal 4566

# Ver logs
kubectl logs -f deployment/payment-deployment
```

### Cleanup

```bash
cd local
./teardown.sh
```

Ou manualmente:

```bash
# Destruir Terraform
cd local/apps-local && terraform destroy -auto-approve
cd ../cloud-base-local && terraform destroy -auto-approve

# Parar containers
cd .. && docker-compose down -v

# Deletar cluster Kind
kind delete cluster --name soat-local
```

### Limitações do LocalStack Free

| Serviço | Free | Pro | Alternativa Local |
|---------|------|-----|-------------------|
| S3 | ✅ | ✅ | - |
| SQS | ✅ | ✅ | - |
| Lambda | ✅ | ✅ | - |
| API Gateway | ✅ | ✅ | - |
| ECR | ❌ | ✅ | `kind load docker-image` |
| Cognito | ❌ | ✅ | Mock ou skip |
| EKS | ❌ | ✅ | Kind |
| RDS | ❌ | ✅ | Docker PostgreSQL |

### Diferenças Local vs Produção

| Aspecto | Produção | Local |
|---------|----------|-------|
| Kubernetes | EKS | Kind |
| AWS | Real | LocalStack |
| Database | RDS/DocumentDB | Docker |
| Images | ECR | kind load |
| Ingress Host | NLB hostname | localhost |
| Resources | 100m-250m CPU | 50m-100m CPU |
| Replicas | 1-2 (HPA) | 1 fixo |

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
