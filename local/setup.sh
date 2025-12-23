#!/bin/bash

set -e

echo "============================================"
echo "  SOAT Local Environment Setup"
echo "============================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    else
        echo -e "${GREEN}✅ $1 is installed${NC}"
        return 0
    fi
}

echo ""
echo "Checking prerequisites..."
echo ""

check_command docker
check_command terraform
check_command kubectl
check_command kind || echo -e "${YELLOW}⚠️  Kind is optional but recommended for K8s testing${NC}"

echo ""
echo "============================================"
echo "  Starting LocalStack..."
echo "============================================"

cd "$(dirname "$0")"
docker-compose up -d

echo ""
echo "Waiting for LocalStack to be ready..."
sleep 5

# Check if LocalStack is ready (compatível com v3+)
MAX_RETRIES=30
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ LocalStack is ready!${NC}"
        break
    fi
    
    # Fallback: verificar se a porta está respondendo
    if curl -s http://localhost:4566 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ LocalStack is ready!${NC}"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "Waiting for LocalStack... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "${YELLOW}⚠️  LocalStack health check timeout, but continuing...${NC}"
fi

echo ""
echo "============================================"
echo "  Creating S3 bucket for Terraform state..."
echo "============================================"

aws --endpoint-url=http://localhost:4566 s3 mb s3://soat-terraform-challenge 2>/dev/null || true
echo -e "${GREEN}✅ S3 bucket created${NC}"

echo ""
echo "============================================"
echo "  Setting up Kind cluster..."
echo "============================================"

if command -v kind &> /dev/null; then
    # Delete existing cluster if exists
    kind delete cluster --name soat-local 2>/dev/null || true
    
    # Create new cluster
    kind create cluster --config kind-config.yaml
    
    echo -e "${GREEN}✅ Kind cluster created!${NC}"
    
    # Install nginx ingress controller
    echo ""
    echo "Installing NGINX Ingress Controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    
    echo ""
    echo "Waiting for ingress controller to be ready..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    
    echo -e "${GREEN}✅ NGINX Ingress Controller installed!${NC}"
else
    echo -e "${YELLOW}⚠️  Kind not installed. Skipping Kubernetes setup.${NC}"
    echo "Install Kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
fi

echo ""
echo "============================================"
echo -e "${GREEN}  Setup Complete!${NC}"
echo "============================================"
echo ""
echo "Services:"
echo "  LocalStack:  http://localhost:4566"
echo "  MongoDB:     mongodb://localhost:27017"
echo "  PostgreSQL:  postgresql://admin:localpassword@localhost:5432/soat_db"
echo ""
echo "AWS CLI:"
echo "  aws --endpoint-url=http://localhost:4566 sqs list-queues"
echo "  aws --endpoint-url=http://localhost:4566 s3 ls"
echo ""
if command -v kind &> /dev/null; then
    echo "Kubernetes:"
    echo "  kubectl cluster-info --context kind-soat-local"
    echo "  kubectl get pods"
    echo ""
fi
echo "Next steps:"
echo ""
echo "  1. Deploy cloud-base (Lambda, Cognito, S3):"
echo "     cd cloud-base-local"
echo "     [ ! -f lambda.zip ] && echo 'exports.handler = async () => ({ statusCode: 200 })' | zip lambda.zip -"
echo "     terraform init && terraform apply -auto-approve"
echo ""
echo "  2. Deploy apps (K8s + API Gateway):"
echo "     cd ../apps-local"
echo "     terraform init -upgrade && terraform apply -auto-approve"
echo ""
echo "  3. Get API Gateway URL:"
echo "     terraform output api_gateway_payment_docs_url"
echo ""

