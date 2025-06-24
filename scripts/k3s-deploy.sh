#!/bin/bash

echo "🐱 Deploying Cheshire Cat to Kubernetes..."

# Create namespace first
echo "Creating namespace..."
kubectl create namespace cheshire-cat --dry-run=client -o yaml | kubectl apply -f -

# Apply secrets from environment variables
echo "Applying secrets from environment variables..."
scripts/apply-secrets.sh

# Create configmaps
echo "Creating configmaps..."
kubectl apply -f k3s/configmaps.yaml

# Deploy all services
echo "Deploying all services..."
kubectl apply -f k3s/k3s-manifest.yaml

# Wait for services to be ready
echo "Waiting for services to be ready..."
kubectl wait --for=condition=available --timeout=180s deployment/qdrant -n cheshire-cat
kubectl wait --for=condition=available --timeout=180s deployment/cheshire-cat-core -n cheshire-cat
kubectl wait --for=condition=available --timeout=60s deployment/nginx -n cheshire-cat

echo "✅ Deployment complete!"
echo ""
echo "🌐 Access your application:"
echo "   - Main application: http://localhost:30080"
echo ""
echo "📊 Check deployment status:"
echo "   kubectl get all -n cheshire-cat"
echo ""
echo "📝 View logs:"
echo "   kubectl logs -f deployment/nginx -n cheshire-cat"
echo "   kubectl logs -f deployment/cheshire-cat-core -n cheshire-cat"
echo "   kubectl logs -f deployment/qdrant -n cheshire-cat" 