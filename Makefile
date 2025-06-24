# 🐱 Cheshire Cat AI - Production Ready
# Makefile for easy deployment and management

.DEFAULT_GOAL := help
.PHONY: help env docker-up docker-down docker-logs docker-clean k3s-deploy k3s-cleanup k3s-secrets k3s-status clean test-scripts

# Colors for output
BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
NC := \033[0m # No Color

##@ Environment Setup

env: ## 🔑 Generate secure environment variables (.env file)
	@echo -e "$(BLUE)🔑 Generating secure environment variables...$(NC)"
	@scripts/generate-env.sh

##@ Docker Deployment

docker-up: ## 🐳 Start Docker deployment
	@echo -e "$(BLUE)🐳 Starting Docker deployment...$(NC)"
	@if [ ! -f .env ]; then \
		echo -e "$(YELLOW)⚠️  No .env file found. Generating one first...$(NC)"; \
		$(MAKE) env; \
	fi
	@cd docker && docker-compose up -d
	@echo -e "$(GREEN)✅ Docker deployment started!$(NC)"
	@echo -e "$(BLUE)🌐 Access at: http://localhost/auth/login$(NC)"

docker-down: ## 🛑 Stop Docker deployment
	@echo -e "$(BLUE)🛑 Stopping Docker deployment...$(NC)"
	@cd docker && docker-compose down
	@echo -e "$(GREEN)✅ Docker deployment stopped!$(NC)"

docker-logs: ## 📝 View Docker deployment logs
	@echo -e "$(BLUE)📝 Viewing Docker logs...$(NC)"
	@cd docker && docker-compose logs -f

docker-status: ## 📊 Check Docker deployment status
	@echo -e "$(BLUE)📊 Docker deployment status:$(NC)"
	@cd docker && docker-compose ps

docker-clean: ## 🧹 Clean Docker deployment (removes volumes)
	@echo -e "$(YELLOW)⚠️  This will remove all data!$(NC)"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@cd docker && docker-compose down -v
	@echo -e "$(GREEN)✅ Docker deployment cleaned!$(NC)"

##@ K3s/Kubernetes Deployment

k3s-deploy: ## ☸️ Deploy to K3s/Kubernetes (one command)
	@echo -e "$(BLUE)☸️ Deploying to K3s...$(NC)"
	@if [ ! -f .env ]; then \
		echo -e "$(YELLOW)⚠️  No .env file found. Generating one first...$(NC)"; \
		$(MAKE) env; \
	fi
	@scripts/k3s-deploy.sh
	@echo -e "$(GREEN)✅ K3s deployment complete!$(NC)"
	@echo -e "$(BLUE)🌐 Access at: http://localhost:30080/auth/login$(NC)"

k3s-cleanup: ## 🗑️ Clean up K3s deployment
	@echo -e "$(BLUE)🗑️ Cleaning up K3s deployment...$(NC)"
	@scripts/k3s-cleanup.sh

k3s-secrets: ## 🔐 Apply secrets to K3s cluster
	@echo -e "$(BLUE)🔐 Applying secrets to K3s...$(NC)"
	@if [ ! -f .env ]; then \
		echo -e "$(RED)❌ No .env file found. Run 'make env' first.$(NC)"; \
		exit 1; \
	fi
	@scripts/apply-secrets.sh
	@echo -e "$(GREEN)✅ Secrets applied!$(NC)"

k3s-status: ## 📊 Check K3s deployment status
	@echo -e "$(BLUE)📊 K3s deployment status:$(NC)"
	@kubectl get all -n cheshire-cat 2>/dev/null || echo -e "$(YELLOW)No cheshire-cat namespace found$(NC)"

k3s-logs: ## 📝 View K3s deployment logs
	@echo -e "$(BLUE)📝 Viewing K3s logs...$(NC)"
	@echo -e "$(BLUE)=== Cheshire Cat Core Logs ===$(NC)"
	@kubectl logs -f deployment/cheshire-cat-core -n cheshire-cat --tail=50

k3s-configmaps: ## ⚙️ Apply ConfigMaps only
	@echo -e "$(BLUE)⚙️ Applying ConfigMaps...$(NC)"
	@kubectl apply -f k3s/configmaps.yaml
	@echo -e "$(GREEN)✅ ConfigMaps applied!$(NC)"

k3s-manifests: ## 📋 Apply main manifests only
	@echo -e "$(BLUE)📋 Applying main manifests...$(NC)"
	@kubectl apply -f k3s/k3s-manifest.yaml
	@echo -e "$(GREEN)✅ Manifests applied!$(NC)"

k3s-test-connection: ## 🔗 Test Cheshire Cat to Qdrant connectivity
	@echo -e "$(BLUE)🔗 Testing Cheshire Cat to Qdrant connectivity...$(NC)"
	@echo -e "$(BLUE)📊 Checking if services are running:$(NC)"
	@kubectl get pods -n cheshire-cat -l app=qdrant
	@kubectl get pods -n cheshire-cat -l app=cheshire-cat-core
	@echo -e "$(BLUE)📡 Testing DNS resolution from Cheshire Cat to Qdrant:$(NC)"
	@kubectl exec -n cheshire-cat deployment/cheshire-cat-core -- nslookup qdrant 2>/dev/null || echo "DNS resolution test failed"
	@echo -e "$(BLUE)🌐 Testing HTTP connectivity to Qdrant:$(NC)"
	@kubectl exec -n cheshire-cat deployment/cheshire-cat-core -- wget -q --spider http://qdrant:6333/ && echo "✅ HTTP connectivity successful" || echo "❌ HTTP connectivity failed"
	@echo -e "$(BLUE)📝 Recent Cheshire Cat logs for Qdrant connections:$(NC)"
	@kubectl logs -n cheshire-cat deployment/cheshire-cat-core --tail=20 | grep -i qdrant || echo "No Qdrant-related logs found"

k3s-restart-cat: ## 🔄 Restart Cheshire Cat pod (useful after config changes)
	@echo -e "\033[33m🔄 Restarting Cheshire Cat...\033[0m"
	kubectl rollout restart deployment/cheshire-cat-core -n cheshire-cat
	kubectl rollout status deployment/cheshire-cat-core -n cheshire-cat
	@echo -e "\033[32m✅ Cheshire Cat restarted!\033[0m"

k3s-restart-nginx: ## Restart NGINX proxy (useful after config changes)
	@echo -e "\033[33m🔄 Restarting NGINX...\033[0m"
	kubectl rollout restart deployment/nginx -n cheshire-cat
	kubectl rollout status deployment/nginx -n cheshire-cat
	@echo -e "\033[32m✅ NGINX restarted!\033[0m"

k3s-debug-env: ## 🔍 Show Cheshire Cat environment variables for debugging
	@echo -e "$(BLUE)🔍 Cheshire Cat environment variables:$(NC)"
	@kubectl exec -n cheshire-cat deployment/cheshire-cat-core -- env | grep -E "(QDRANT|CCAT)" | sort

##@ Development & Testing

test-scripts: ## 🧪 Test that all scripts are executable and accessible
	@echo -e "$(BLUE)🧪 Testing scripts...$(NC)"
	@echo "Testing generate-env.sh..."
	@test -x scripts/generate-env.sh && echo "✅ generate-env.sh is executable" || echo "❌ generate-env.sh not executable"
	@echo "Testing apply-secrets.sh..."
	@test -x scripts/apply-secrets.sh && echo "✅ apply-secrets.sh is executable" || echo "❌ apply-secrets.sh not executable"
	@echo "Testing k3s-deploy.sh..."
	@test -x scripts/k3s-deploy.sh && echo "✅ k3s-deploy.sh is executable" || echo "❌ k3s-deploy.sh not executable"
	@echo "Testing k3s-cleanup.sh..."
	@test -x scripts/k3s-cleanup.sh && echo "✅ k3s-cleanup.sh is executable" || echo "❌ k3s-cleanup.sh not executable"
	@echo -e "$(GREEN)✅ Script tests complete!$(NC)"

check-requirements: ## 🔍 Check system requirements
	@echo -e "$(BLUE)🔍 Checking system requirements...$(NC)"
	@command -v docker >/dev/null 2>&1 && echo "✅ Docker found" || echo "❌ Docker not found"
	@command -v docker-compose >/dev/null 2>&1 && echo "✅ Docker Compose found" || echo "❌ Docker Compose not found"
	@command -v kubectl >/dev/null 2>&1 && echo "✅ kubectl found" || echo "❌ kubectl not found"
	@command -v openssl >/dev/null 2>&1 && echo "✅ OpenSSL found" || echo "❌ OpenSSL not found"

##@ Maintenance

clean: ## 🧹 General cleanup (removes .env backups and temp files)
	@echo -e "$(BLUE)🧹 Cleaning up temporary files...$(NC)"
	@rm -f .env.backup_*
	@echo -e "$(GREEN)✅ Cleanup complete!$(NC)"

show-env: ## 👀 Show current environment variables (masked for security)
	@if [ -f .env ]; then \
		echo -e "$(BLUE)📄 Current environment variables:$(NC)"; \
		grep -E '^[A-Z_]+=' .env | sed 's/=.*/=***MASKED***/' || true; \
	else \
		echo -e "$(YELLOW)⚠️  No .env file found$(NC)"; \
	fi

##@ Help

help: ## 📚 Show this help message
	@echo -e "$(BLUE)"
	@echo -e "🐱 Cheshire Cat AI - Production Ready"
	@echo -e "====================================="
	@echo -e "$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[33m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo -e "$(GREEN)Quick Start:$(NC)"
	@echo -e "  make env docker-up     # 🐳 Start with Docker"
	@echo -e "  make env k3s-deploy    # ☸️  Start with K3s"
	@echo ""
	@echo -e "$(YELLOW)Examples:$(NC)"
	@echo -e "  make env               # Generate secure keys"
	@echo -e "  make docker-up         # Start Docker deployment"
	@echo -e "  make k3s-deploy        # Deploy to K3s"
	@echo -e "  make k3s-status        # Check K3s status"
	@echo -e "  make clean             # Clean temporary files"
	@echo "" 