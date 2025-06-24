#!/bin/bash

# Load environment variables from .env file
if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    export $(grep -v '^#' .env | xargs)
else
    echo "Warning: .env file not found in root directory"
    echo "Please run scripts/generate-env.sh first to create secure keys"
    exit 1
fi

# Check if required environment variables are set
required_vars=("JWT_SECRET" "API_KEY" "API_KEY_WS" "QDRANT_API_KEY")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set in .env file"
        exit 1
    fi
done

# Apply the secrets with environment variable substitution
echo "Applying Kubernetes secrets..."
envsubst < k3s/secrets.yaml | kubectl apply -f -

echo "Secrets applied successfully!" 