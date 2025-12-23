# Local Testing Environment

Este diretório contém configurações para testar a infraestrutura localmente usando:

- **LocalStack** - Simula serviços AWS (S3, Lambda, API Gateway, Cognito, ECR)
- **Kind** - Simula Kubernetes localmente

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

### 2. Testar Cloud Base (AWS Services)

```bash
cd local/cloud-base-local

# Criar um lambda.zip de teste
zip lambda.zip -j ../../cloud-base/modules/lambda/lambda.zip 2>/dev/null || \
  echo 'exports.handler = async () => ({ statusCode: 200 })' | zip lambda.zip -

# Aplicar
terraform init
terraform apply -auto-approve
```

### 3. Testar Apps (Kubernetes)

```bash
cd local/apps-local

terraform init
terraform apply -auto-approve
```

### 4. Verificar recursos

```bash
# LocalStack - Listar buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# LocalStack - Listar Lambdas
aws --endpoint-url=http://localhost:4566 lambda list-functions

# Kind - Listar pods
kubectl get pods -A

# Kind - Listar services
kubectl get svc

# Kind - Listar ingress
kubectl get ingress
```

### 5. Testar endpoints

```bash
# API Gateway (LocalStack)
curl http://localhost:4566/restapis

# Kubernetes Services
curl http://localhost/payment/
curl http://localhost/cart/
curl http://localhost/admin/
```

## Estrutura

```
local/
├── docker-compose.yml      # LocalStack container
├── kind-config.yaml        # Kind cluster config
├── setup.sh                # Script de setup
├── teardown.sh             # Script de cleanup
├── provider-local.tf       # Provider config para LocalStack
├── backend-local.tf        # Backend local (não usa S3)
├── cloud-base-local/       # Versão local do cloud-base
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
└── apps-local/             # Versão local dos apps
    ├── main.tf
    ├── variables.tf
    └── provider.tf
```

## Limitações

| Recurso | LocalStack Free | Alternativa Local |
|---------|-----------------|-------------------|
| VPC | ❌ Não suportado | Não necessário localmente |
| EKS | ❌ Só na versão Pro | Kind/Minikube |
| RDS | ❌ Só na versão Pro | PostgreSQL Docker |
| S3 | ✅ Funciona | - |
| Lambda | ✅ Funciona | - |
| API Gateway | ✅ Funciona | - |
| ECR | ✅ Funciona | Docker Registry local |
| Cognito | ⚠️ Parcial | - |

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

## PostgreSQL Local (opcional)

Se precisar de um banco de dados local:

```bash
docker run -d \
  --name postgres-local \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=localpassword \
  -e POSTGRES_DB=soat_db \
  -p 5432:5432 \
  postgres:15-alpine
```

