#!/bin/bash

set -e

echo "============================================"
echo "  SOAT Local Environment Teardown"
echo "============================================"

cd "$(dirname "$0")"

# Stop Kind cluster
if command -v kind &> /dev/null; then
    echo "Deleting Kind cluster..."
    kind delete cluster --name soat-local 2>/dev/null || true
    echo "✅ Kind cluster deleted"
fi

# Stop LocalStack
echo "Stopping LocalStack..."
docker-compose down -v
echo "✅ LocalStack stopped"

# Clean up volume
rm -rf volume/

echo ""
echo "============================================"
echo "  Teardown Complete!"
echo "============================================"

