# Local Testing Environment

Este diretório contém configurações para testar a infraestrutura localmente usando:

- **LocalStack** - Simula serviços AWS (S3, Lambda, API Gateway, SQS)
- **Kind** - Simula Kubernetes localmente

## 🔄 Módulos 100% Compartilhados

O ambiente local **reutiliza os mesmos módulos de produção** com a flag `is_local=true`:

| Módulo | Produção | Local |
|--------|----------|-------|
| `cloud-base/modules/lambda` | ✅ Usado | ✅ Mesmo módulo com `is_local=true` |
| `cloud-base/modules/cognito` | ✅ Usado | ✅ Mesmo módulo (mock quando local) |
| `cloud-base/modules/bucket` | ✅ Usado | ✅ Mesmo módulo |
| `apps/modules/api-gateway` | ✅ Usado | ✅ Mesmo módulo |
| `apps/payment` | ✅ Usado | ✅ Mesmo módulo |
| `shared-modules/*` | ✅ Usado | ✅ Mesmos módulos |

Isso garante que **qualquer mudança em produção é automaticamente refletida no ambiente local**.

## Pré-requisitos

```bash
# Obrigatórios
brew install docker
brew install terraform
brew install kubectl

# Opcionais (para K8s local)
brew install kind
```

## Quick Start

### 1. Iniciar o ambiente local

```bash
cd local
chmod +x setup.sh teardown.sh
./setup.sh
```

Isso irá:
- Iniciar LocalStack no Docker
- Criar bucket S3 para o state do Terraform
- Criar cluster Kind (se instalado)
- Instalar NGINX Ingress Controller

### 2. Aplicar Cloud Base (AWS Services)

```bash
cd local/cloud-base-local

# Criar um lambda.zip de teste (se não existir)
[ ! -f lambda.zip ] && echo 'exports.handler = async () => ({ statusCode: 200 })' | zip lambda.zip -

# Aplicar
terraform init
terraform apply -auto-approve
```

### 3. Aplicar Apps (Kubernetes + API Gateway)

```bash
cd local/apps-local

terraform init -upgrade
terraform apply -auto-approve
```

### 4. Verificar recursos

```bash
# LocalStack - Listar buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# LocalStack - Listar Lambdas
aws --endpoint-url=http://localhost:4566 lambda list-functions

# LocalStack - Listar API Gateways
aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis

# Kind - Listar pods
kubectl get pods -A

# Kind - Listar services
kubectl get svc

# Kind - Listar ingress
kubectl get ingress
```

### 5. Testar endpoints

```bash
# Pegar URLs do Terraform
cd apps-local
terraform output api_gateway_payment_url
terraform output api_gateway_payment_docs_url

# Ou manualmente:
API_ID=$(aws --endpoint-url=http://localhost:4566 apigateway get-rest-apis --query 'items[0].id' --output text)

# API Gateway -> Payment (simula produção 100%)
curl http://localhost:4566/restapis/$API_ID/prod/_user_request_/payment
curl http://localhost:4566/restapis/$API_ID/prod/_user_request_/payment/api/docs

# Acesso direto via NGINX Ingress (bypassa API Gateway)
curl http://localhost/payment/
curl http://localhost/payment/api/docs
```

## Arquitetura

```
PRODUÇÃO:
┌─────────┐    ┌─────────────┐    ┌───────────────┐    ┌──────────────┐
│ Internet│───▶│ API Gateway │───▶│ NGINX Ingress │───▶│ K8s Services │
└─────────┘    └─────────────┘    │    (NLB)      │    └──────────────┘
                                  └───────────────┘

LOCAL (100% espelhado):
┌─────────┐    ┌─────────────────┐    ┌───────────────┐    ┌──────────────┐
│ Browser │───▶│ LocalStack      │───▶│ NGINX Ingress │───▶│ K8s Services │
└─────────┘    │ API Gateway     │    │    (Kind)     │    │   (Kind)     │
               │ (localhost:4566)│    │               │    └──────────────┘
               └─────────────────┘    └───────────────┘
                      │
                      ▼ host.docker.internal
```

## Estrutura

```
local/
├── docker-compose.yml          # LocalStack + MongoDB + PostgreSQL
├── kind-config.yaml            # Kind cluster config
├── setup.sh                    # Script de setup
├── teardown.sh                 # Script de cleanup
├── cloud-base-local/           # Usa módulos de ../../cloud-base/modules/
│   ├── main.tf                 # Chama módulos com is_local=true
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf             # Provider LocalStack
└── apps-local/                 # Usa módulos de ../../apps/ e ../../shared-modules/
    ├── main.tf                 # Chama módulos com is_local=true
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

## Limitações LocalStack Free

| Recurso | LocalStack Free | Alternativa Local |
|---------|-----------------|-------------------|
| VPC | ❌ Não suportado | Não necessário localmente |
| EKS | ❌ Só na versão Pro | Kind/Minikube |
| RDS | ❌ Só na versão Pro | PostgreSQL Docker |
| S3 | ✅ Funciona | - |
| Lambda | ✅ Funciona | - |
| API Gateway | ✅ Funciona | - |
| SQS | ✅ Funciona | - |
| ECR | ⚠️ Limitado | Docker Registry local |
| Cognito | ❌ Não suportado | Mock via SSM Parameters |

## Cleanup

```bash
./teardown.sh
```

Ou manualmente:

```bash
# Destruir recursos Terraform
cd apps-local && terraform destroy -auto-approve
cd ../cloud-base-local && terraform destroy -auto-approve

# Parar containers
docker-compose down -v

# Deletar cluster Kind
kind delete cluster --name soat-local
```
