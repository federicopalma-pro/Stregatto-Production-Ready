#!/bin/bash

# 🐱 Cheshire Cat AI - Environment Generator
# 🔐 Automatically generates secure API keys and JWT secrets

set -e

echo "🐱 Cheshire Cat AI - Environment Setup"
echo "🔐 Generating secure keys for your deployment..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to generate secure random string
generate_key() {
    local length=$1
    local type=$2
    
    if command -v openssl >/dev/null 2>&1; then
        if [ "$type" = "hex" ]; then
            openssl rand -hex $length
        else
            openssl rand -base64 $length | tr -d "=+/" | cut -c1-$length
        fi
    elif command -v head >/dev/null 2>&1 && [ -f /dev/urandom ]; then
        if [ "$type" = "hex" ]; then
            head -c $length /dev/urandom | xxd -p | tr -d '\n'
        else
            head -c $length /dev/urandom | base64 | tr -d "=+/\n" | cut -c1-$length
        fi
    else
        echo -e "${RED}Error: Neither openssl nor /dev/urandom available for key generation${NC}"
        exit 1
    fi
}

# Check if .env already exists
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file already exists!${NC}"
    read -p "Do you want to backup the existing .env and create a new one? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        timestamp=$(date +"%Y%m%d_%H%M%S")
        cp .env ".env.backup_$timestamp"
        echo -e "${GREEN}✅ Backed up existing .env to .env.backup_$timestamp${NC}"
    else
        echo -e "${YELLOW}❌ Operation cancelled. Existing .env preserved.${NC}"
        exit 0
    fi
fi

echo -e "${BLUE}🔑 Generating secure keys...${NC}"

# Generate keys with appropriate lengths and formats
echo "Generating JWT secret (64 characters)..."
JWT_SECRET=$(generate_key 64 "base64")

echo "Generating API key (32 characters)..."
API_KEY=$(generate_key 32 "base64")

echo "Generating WebSocket API key (32 characters)..."
API_KEY_WS=$(generate_key 32 "base64")

echo "Generating Qdrant API key (32 characters)..."
QDRANT_API_KEY=$(generate_key 32 "base64")

# Create the .env file
cat > .env << EOF
# 🐱 Cheshire Cat AI 
# 🔐 Security Settings
# Generated on: $(date)
# 
# WARNING: Keep this file secure and never commit it to version control!
# These keys provide access to your AI system.

# JWT Secret for authentication tokens
# Used by: Cheshire Cat Core for user authentication
JWT_SECRET=$JWT_SECRET

# Main API authentication key  
# Used by: REST API endpoints for request authentication
API_KEY=$API_KEY

# WebSocket API authentication key
# Used by: Real-time WebSocket connections (/ws endpoint)
API_KEY_WS=$API_KEY_WS

# Qdrant vector database API key
# Used by: Vector database for securing AI memory and embeddings
QDRANT_API_KEY=$QDRANT_API_KEY
EOF

echo ""
echo -e "${GREEN}✅ Environment file created successfully!${NC}"
echo ""
echo -e "${BLUE}📁 File details:${NC}"
echo "   • Location: $(pwd)/.env"
echo "   • Permissions: $(ls -la .env | cut -d' ' -f1)"
echo ""
echo -e "${BLUE}🔐 Generated keys:${NC}"
echo "   • JWT_SECRET: 64 characters (base64)"
echo "   • API_KEY: 32 characters (base64)" 
echo "   • API_KEY_WS: 32 characters (base64)"
echo "   • QDRANT_API_KEY: 32 characters (base64)"
echo ""
echo -e "${YELLOW}⚠️  Security reminders:${NC}"
echo "   • Keep your .env file secure and private"
echo "   • Never commit .env to version control"
echo "   • Consider rotating keys periodically"
echo "   • Use different keys for different environments"
echo ""
echo -e "${GREEN}🚀 Ready to deploy!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "   • Docker: cd docker && docker-compose up -d"
echo "   • K3s: cd k3s && ./apply-secrets.sh && kubectl apply -f k3s-manifest.yaml"
echo "" 