# Cheshire Cat AI Helm Chart

A Helm chart for deploying Cheshire Cat AI with Qdrant vector database in Kubernetes.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- A storage class that supports `ReadWriteOnce` volumes (default: `local-path`)

## Installation

### Quick Start

1. Clone the repository and navigate to the Helm chart:
```bash
git clone <repository-url>
cd helm/cheshire-cat
```

2. Install the chart with default values:
```bash
helm install cheshire-cat . --namespace cheshire-cat --create-namespace
```

3. Access the application:
```bash
# Get the application URL
kubectl get service nginx -n cheshire-cat

# If using NodePort (default):
# The application will be available at http://<node-ip>:30080
```

### Custom Installation

1. Copy and customize the values:
```bash
cp values.yaml my-values.yaml
# Edit my-values.yaml with your specific configuration
```

2. Install with custom values:
```bash
helm install cheshire-cat . -f my-values.yaml --namespace cheshire-cat --create-namespace
```

## Configuration

The following table lists the configurable parameters and their default values.

### Global Settings
| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.namespace` | Kubernetes namespace | `cheshire-cat` |
| `global.storageClass` | Storage class for PVCs | `local-path` |

### Application Images
| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Cheshire Cat image repository | `ghcr.io/cheshire-cat-ai/core` |
| `image.tag` | Cheshire Cat image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Replica Counts
| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount.cheshireCat` | Number of Cheshire Cat replicas | `1` |
| `replicaCount.qdrant` | Number of Qdrant replicas | `1` |
| `replicaCount.nginx` | Number of NGINX replicas | `1` |

### Service Configuration
| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `NodePort` |
| `service.port` | Service port | `80` |
| `service.nodePort` | NodePort (when type is NodePort) | `30080` |

### Persistence
| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.storageClass` | Storage class | `local-path` |
| `persistence.qdrant.size` | Qdrant storage size | `10Gi` |
| `persistence.static.size` | Static files storage size | `1Gi` |
| `persistence.plugins.size` | Plugins storage size | `5Gi` |
| `persistence.data.size` | Data storage size | `5Gi` |

### Security
| Parameter | Description | Default |
|-----------|-------------|---------|
| `secrets.jwtSecret` | JWT secret key | `change-me-jwt-secret-key` |
| `secrets.apiKey` | API key | `change-me-api-key` |
| `secrets.apiKeyWs` | WebSocket API key | `change-me-api-key-ws` |
| `secrets.qdrantApiKey` | Qdrant API key | `change-me-qdrant-api-key` |

### Cheshire Cat Configuration
| Parameter | Description | Default |
|-----------|-------------|---------|
| `cheshireCat.debug` | Enable debug mode | `true` |
| `cheshireCat.logLevel` | Log level | `INFO` |
| `cheshireCat.cors.enabled` | Enable CORS | `true` |
| `cheshireCat.cors.allowedOrigins` | Allowed CORS origins | `http://localhost` |

## Security Considerations

### Production Deployment

**⚠️ Important**: Before deploying to production, you must change the default secret values:

```yaml
secrets:
  jwtSecret: "your-secure-jwt-secret-here"
  apiKey: "your-secure-api-key-here"
  apiKeyWs: "your-secure-websocket-key-here"
  qdrantApiKey: "your-secure-qdrant-key-here"
```

### Recommended Security Practices

1. **Use External Secret Management**: Consider using tools like:
   - Kubernetes External Secrets Operator
   - HashiCorp Vault
   - Azure Key Vault
   - AWS Secrets Manager

2. **Network Policies**: Implement Kubernetes Network Policies to restrict traffic between pods.

3. **RBAC**: Configure proper Role-Based Access Control.

4. **TLS/SSL**: Enable TLS for production deployments by configuring ingress with SSL certificates.

## Upgrading

To upgrade an existing installation:

```bash
helm upgrade cheshire-cat . -f my-values.yaml --namespace cheshire-cat
```

## Uninstalling

To uninstall the chart:

```bash
helm uninstall cheshire-cat --namespace cheshire-cat
```

**Note**: This will not delete the PVCs by default. To delete them:

```bash
kubectl delete pvc -l app=cheshire-cat -n cheshire-cat
kubectl delete pvc qdrant-storage-pvc -n cheshire-cat
```

## Accessing the Application

### Web Interface
- **URL**: `http://<node-ip>:30080` (NodePort) or configured ingress URL
- **API Documentation**: `http://<node-ip>:30080/docs`

### WebSocket Connection
- **WebSocket URL**: `ws://<node-ip>:30080/ws`

## Troubleshooting

### Common Issues

1. **PVC Binding Issues**:
   ```bash
   kubectl get pvc -n cheshire-cat
   kubectl describe pvc <pvc-name> -n cheshire-cat
   ```

2. **Pod Not Starting**:
   ```bash
   kubectl get pods -n cheshire-cat
   kubectl describe pod <pod-name> -n cheshire-cat
   kubectl logs <pod-name> -n cheshire-cat
   ```

3. **Service Connectivity**:
   ```bash
   kubectl get svc -n cheshire-cat
   kubectl port-forward svc/nginx 8080:80 -n cheshire-cat
   ```

### Logs

View application logs:
```bash
# Cheshire Cat logs
kubectl logs -l app=cheshire-cat-core -n cheshire-cat -f

# Qdrant logs
kubectl logs -l app=qdrant -n cheshire-cat -f

# NGINX logs
kubectl logs -l app=nginx -n cheshire-cat -f
```

## Development

### Local Development

For local development with minikube or kind:

```bash
# Install with development values
helm install cheshire-cat . \
  --set cheshireCat.debug=true \
  --set cheshireCat.logLevel=DEBUG \
  --namespace cheshire-cat \
  --create-namespace
```

### Testing

Test the Helm chart:
```bash
# Dry run
helm install cheshire-cat . --dry-run --debug

# Template rendering
helm template cheshire-cat .

# Lint
helm lint .
```

## Support

For issues and questions:
- [GitHub Issues](https://github.com/cheshire-cat-ai/core/issues)
- [Documentation](https://cheshire-cat-ai.github.io/docs/)
- [Discord Community](https://discord.gg/bHX5sNFCYU)

## License

This chart is licensed under the GPL-3.0 License. See the [LICENSE](../../LICENSE) file for details. 