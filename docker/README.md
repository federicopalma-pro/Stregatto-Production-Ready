# Docker Deployment

This directory contains the Docker Compose setup for local development and testing of Cheshire Cat AI.

## 📁 Files Overview

- `docker-compose.yml` - **Main Docker Compose configuration**
- `nginx/` - **NGINX configuration directory**
  - `nginx-local.conf` - NGINX reverse proxy configuration

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose (or Podman with podman-compose)
- 4GB RAM minimum (8GB recommended)
- 2 CPU cores minimum

### Deploy with Docker Compose
```bash
# Make sure you're in the project root first
cd /path/to/Stregatto-Production-Ready

# 🔑 Auto-generate secure keys (Recommended)
scripts/generate-env.sh

# Navigate to docker directory and start
cd docker
docker-compose up -d
```

### Deploy with Podman
```bash
# Make sure you're in the project root first
cd /path/to/Stregatto-Production-Ready

# 🔑 Auto-generate secure keys (Recommended)
scripts/generate-env.sh

# Navigate to docker directory and start
cd docker
podman-compose up -d
```

### Verify Deployment
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Check individual service logs
docker-compose logs cheshire-cat-core
docker-compose logs qdrant
docker-compose logs nginx
```

### Access the Application
- **Main Application**: http://localhost/auth/login
- **Qdrant Dashboard**: http://localhost:6333/dashboard

### Stop Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ This will delete all data)
docker-compose down -v
```

## 🔧 Configuration

### Environment Variables
The deployment uses environment variables defined in the `.env` file in the project root. Key variables include:

- `CCAT_JWT_SECRET` - JWT signing secret
- `CCAT_API_KEY` - API authentication key
- `CCAT_API_KEY_WS` - WebSocket API key
- `QDRANT_API_KEY` - Qdrant database API key

### Volumes
The setup uses Docker volumes for persistent data:
- `qdrant_storage` - Qdrant vector database data
- `cat_static` - Static files served by NGINX
- `cat_plugins` - Cheshire Cat plugins
- `cat_data` - Application data and configurations

### Services Architecture
```
🌐 NGINX (Port 80) → Reverse Proxy
         ↓
🐱 Cheshire Cat Core (Port 1865) → AI Application
         ↓
💾 Qdrant (Port 6333) → Vector Database
``` 