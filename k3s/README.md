# K3s/Kubernetes Deployment

This directory contains all the necessary Kubernetes manifests to deploy Cheshire Cat AI on K3s or any Kubernetes cluster.

## 📁 Files Overview

- `k3s-manifest.yaml` - **Main deployment manifest** containing all core resources (namespace, PVCs, deployments, services)
- `secrets.yaml` - **Secrets configuration** (JWT secrets, API keys, etc.) - Uses environment variables from root `.env` file
- `../scripts/apply-secrets.sh` - **Script to apply secrets** from environment variables
- `configmaps.yaml` - **ConfigMaps** (NGINX configuration)
- `README-kubernetes.md` - **Detailed documentation** about the Kubernetes deployment
- `../scripts/k3s-deploy.sh` - **Automated deployment script**
- `../scripts/k3s-cleanup.sh` - **Cleanup script** for removing all resources

## 🚀 Quick Deployment

### 1. Configure Environment Variables
Create and configure your environment file:
```bash
# 🔑 Auto-generate secure keys (Recommended) 
../scripts/generate-env.sh

# Or manual setup:
# cp ../.env-sample ../.env && nano ../.env
```

Example `.env` content:
```bash
JWT_SECRET=your-secure-jwt-secret-here
API_KEY=your-api-key-here
API_KEY_WS=your-websocket-api-key-here
QDRANT_API_KEY=your-qdrant-api-key-here
```

### 2. Deploy Everything
```bash
# Apply secrets from environment variables
../scripts/apply-secrets.sh

# Apply configmaps
kubectl apply -f configmaps.yaml

# Deploy all services
kubectl apply -f k3s-manifest.yaml
```

### 3. Verify Deployment
```bash
# Check pods status
kubectl get pods -n cheshire-cat

# Check services
kubectl get svc -n cheshire-cat

# View logs
kubectl logs -f deployment/cheshire-cat-core -n cheshire-cat
```

### 4. Access the Application
- **Main Application**: http://localhost:30080
- **Qdrant Dashboard**: http://localhost:30633

## 🗑️ Cleanup
To remove all resources:
```bash
../scripts/k3s-cleanup.sh
# or manually:
kubectl delete namespace cheshire-cat
```

## 📋 Architecture

The deployment includes:
- **Namespace**: `cheshire-cat` - Isolated environment
- **Persistent Volumes**: Data persistence for Qdrant, static files, plugins, and application data
- **Services**:
  - `qdrant` - Vector database (NodePort 30633)
  - `cheshire-cat-core` - Main AI application (ClusterIP)
  - `nginx` - Reverse proxy and load balancer (NodePort 30080)

## 🔧 Configuration

### Environment Variables
The deployment now uses environment variables from the root `.env` file for sensitive data:
- **JWT_SECRET**: Secure JWT signing key
- **API_KEY**: Main API authentication key  
- **API_KEY_WS**: WebSocket API authentication key
- **QDRANT_API_KEY**: Qdrant vector database API key

The `../scripts/apply-secrets.sh` script automatically reads these values and applies them as Kubernetes secrets using `envsubst`.

### Storage
All services use persistent storage with the `local-path` storage class (default in K3s).
Storage sizes:
- Qdrant: 10Gi
- Static files: 1Gi  
- Plugins: 5Gi
- Application data: 5Gi
