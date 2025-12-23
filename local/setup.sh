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
sleep 10

# Check if LocalStack is ready
until curl -s http://localhost:4566/_localstack/health | grep -q '"s3": "available"'; do
    echo "Waiting for LocalStack..."
    sleep 2
done

echo -e "${GREEN}✅ LocalStack is ready!${NC}"

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
echo "LocalStack: http://localhost:4566"
echo "AWS CLI:    aws --endpoint-url=http://localhost:4566 <command>"
echo ""
if command -v kind &> /dev/null; then
    echo "Kubernetes: kubectl cluster-info --context kind-soat-local"
    echo ""
fi
echo "Next steps:"
echo "  1. cd cloud-base"
echo "  2. Copy ../local/provider-local.tf to provider.tf"
echo "  3. Copy ../local/backend-local.tf to backend.tf"
echo "  4. terraform init && terraform apply"
echo ""

