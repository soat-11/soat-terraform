#!/bin/bash

echo "============================================"
echo "  SOAT Local Environment Teardown"
echo "============================================"

cd "$(dirname "$0")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Destroy Terraform resources (apps-local first, then cloud-base-local)
echo ""
echo "Destroying Terraform resources..."

if [ -d "apps-local" ] && [ -f "apps-local/terraform.tfstate" ]; then
    echo "Destroying apps-local..."
    cd apps-local
    terraform destroy -auto-approve 2>/dev/null || echo -e "${YELLOW}⚠️  apps-local destroy skipped (no state or error)${NC}"
    cd ..
    echo -e "${GREEN}✅ apps-local destroyed${NC}"
fi

if [ -d "cloud-base-local" ] && [ -f "cloud-base-local/terraform.tfstate" ]; then
    echo "Destroying cloud-base-local..."
    cd cloud-base-local
    terraform destroy -auto-approve 2>/dev/null || echo -e "${YELLOW}⚠️  cloud-base-local destroy skipped (no state or error)${NC}"
    cd ..
    echo -e "${GREEN}✅ cloud-base-local destroyed${NC}"
fi

# Stop Kind cluster
if command -v kind &> /dev/null; then
    echo ""
    echo "Deleting Kind cluster..."
    kind delete cluster --name soat-local 2>/dev/null || true
    echo -e "${GREEN}✅ Kind cluster deleted${NC}"
fi

# Stop LocalStack and other containers
echo ""
echo "Stopping Docker containers..."
docker-compose down -v 2>/dev/null || docker compose down -v 2>/dev/null || true
echo -e "${GREEN}✅ Docker containers stopped${NC}"

# Clean up volumes (optional - ask user)
echo ""
read -p "Remove local data (mongo-data, postgres-data, volume)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf volume/ mongo-data/ postgres-data/
    echo -e "${GREEN}✅ Local data removed${NC}"
else
    echo -e "${YELLOW}⚠️  Local data preserved${NC}"
fi

echo ""
echo "============================================"
echo -e "${GREEN}  Teardown Complete!${NC}"
echo "============================================"

