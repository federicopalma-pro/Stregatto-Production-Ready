#!/bin/bash

echo "🗑️ Cleaning up Cheshire Cat Kubernetes deployment..."
echo ""

# Check if namespace exists
if ! kubectl get namespace cheshire-cat &> /dev/null; then
    echo "ℹ️  Namespace 'cheshire-cat' does not exist. Nothing to clean up."
    exit 0
fi

# Show current resources before cleanup
echo "📋 Current resources in cheshire-cat namespace:"
kubectl get all -n cheshire-cat
echo ""

# Confirm cleanup
read -p "❓ Are you sure you want to delete all Cheshire Cat resources? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 0
fi

echo "🔄 Starting cleanup process..."
echo ""

# Delete main deployment (this will remove deployments, services, etc.)
echo "Deleting main deployment resources..."
kubectl delete -f k3s/k3s-manifest.yaml --ignore-not-found --wait=true

# Delete configmaps
echo "Deleting configmaps..."
kubectl delete -f k3s/configmaps.yaml --ignore-not-found

# Delete secrets
echo "Deleting secrets..."
kubectl delete secret cheshire-cat-secrets -n cheshire-cat --ignore-not-found

# Wait a moment for resources to be cleaned up
echo "Waiting for resources to be cleaned up..."
sleep 5

# Show any remaining resources
echo "📋 Checking for remaining resources..."
REMAINING=$(kubectl get all -n cheshire-cat --no-headers 2>/dev/null | wc -l)
if [ "$REMAINING" -gt 0 ]; then
    echo "⚠️  Some resources still exist:"
    kubectl get all -n cheshire-cat
    echo ""
    read -p "❓ Force delete the namespace? This will remove all remaining resources (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️ Force deleting namespace..."
        kubectl delete namespace cheshire-cat --force --grace-period=0
    fi
else
    echo "✅ All resources cleaned up successfully!"
fi

# Delete namespace (this will delete any remaining resources)
echo "Deleting namespace..."
kubectl delete namespace cheshire-cat --ignore-not-found

# Final verification
echo ""
echo "🔍 Final verification..."
if kubectl get namespace cheshire-cat &> /dev/null; then
    echo "⚠️  Namespace still exists. Some resources may still be terminating."
    echo "   You can check status with: kubectl get all -n cheshire-cat"
else
    echo "✅ Cleanup complete! All Cheshire Cat resources have been removed."
fi

echo ""
echo "📝 Note: Persistent data on the host system (if any) is not automatically removed."
echo "   Check your local storage paths if you want to remove data completely." 