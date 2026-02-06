.PHONY: help build run test clean logs up down scan push

# Docker & Container Management Makefile
# Utility commands for building, running, and managing containers

DOCKER_REGISTRY ?= myregistry.azurecr.io
APP_NAME ?= app
APP_VERSION ?= 1.0.0
IMAGE := $(DOCKER_REGISTRY)/$(APP_NAME):$(APP_VERSION)
LATEST := $(DOCKER_REGISTRY)/$(APP_NAME):latest

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(CYAN)Docker Management Commands$(NC)"
	@echo "$(CYAN)=========================$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(CYAN)Environment Variables$(NC)"
	@echo "DOCKER_REGISTRY=$(DOCKER_REGISTRY)"
	@echo "APP_NAME=$(APP_NAME)"
	@echo "APP_VERSION=$(APP_VERSION)"

# =====================================================================
# BUILD COMMANDS
# =====================================================================

build: ## Build Docker image
	@echo "$(CYAN)Building image: $(IMAGE)$(NC)"
	DOCKER_BUILDKIT=1 docker build \
		--tag $(IMAGE) \
		--tag $(LATEST) \
		--build-arg VERSION=$(APP_VERSION) \
		--build-arg BUILD_DATE=$$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
		.
	@echo "$(GREEN)✓ Build complete$(NC)"

build-no-cache: ## Build without using cache
	@echo "$(CYAN)Building image (no-cache): $(IMAGE)$(NC)"
	DOCKER_BUILDKIT=1 docker build \
		--no-cache \
		--tag $(IMAGE) \
		--tag $(LATEST) \
		.
	@echo "$(GREEN)✓ Build complete$(NC)"

build-debug: ## Build debug stage
	@echo "$(CYAN)Building debug image: $(APP_NAME):debug$(NC)"
	docker build \
		--target debug \
		--tag $(APP_NAME):debug \
		.
	@echo "$(GREEN)✓ Debug build complete$(NC)"

# =====================================================================
# RUN COMMANDS
# =====================================================================

run: ## Run container locally
	@echo "$(CYAN)Running container: $(APP_NAME)$(NC)"
	docker run \
		--name $(APP_NAME) \
		--rm \
		-it \
		-p 3000:3000 \
		-e NODE_ENV=development \
		-e LOG_LEVEL=debug \
		$(IMAGE)

run-prod: ## Run container in production mode
	@echo "$(CYAN)Running container (production): $(APP_NAME)$(NC)"
	docker run \
		--name $(APP_NAME) \
		--rm \
		-d \
		-p 3000:3000 \
		-e NODE_ENV=production \
		-e LOG_LEVEL=info \
		--health-interval=30s \
		--health-timeout=10s \
		--health-retries=3 \
		$(IMAGE)

compose-up: ## Start services with docker-compose
	@echo "$(CYAN)Starting services with docker-compose$(NC)"
	docker-compose up -d
	@echo "$(GREEN)✓ Services started$(NC)"
	docker-compose ps

compose-down: ## Stop services with docker-compose
	@echo "$(CYAN)Stopping services$(NC)"
	docker-compose down
	@echo "$(GREEN)✓ Services stopped$(NC)"

compose-logs: ## View docker-compose logs
	docker-compose logs -f

compose-logs-app: ## View app logs only
	docker-compose logs -f app

# =====================================================================
# TESTING & VALIDATION
# =====================================================================

test: ## Run tests
	@echo "$(CYAN)Running tests$(NC)"
	npm test
	@echo "$(GREEN)✓ Tests passed$(NC)"

test-image: build ## Test image functionality
	@echo "$(CYAN)Testing image: $(IMAGE)$(NC)"
	docker run --rm $(IMAGE) npm run test:unit
	@echo "$(GREEN)✓ Image tests passed$(NC)"

health-check: ## Check container health
	@echo "$(CYAN)Checking container health$(NC)"
	curl -f http://localhost:3000/health && echo "$(GREEN)✓ Healthy$(NC)" || echo "$(RED)✗ Unhealthy$(NC)"

lint: ## Lint Dockerfile
	@echo "$(CYAN)Linting Dockerfile$(NC)"
	hadolint Dockerfile
	@echo "$(GREEN)✓ Dockerfile valid$(NC)"

scan: ## Scan image for vulnerabilities with Trivy
	@echo "$(CYAN)Scanning image: $(IMAGE)$(NC)"
	trivy image --severity HIGH,CRITICAL $(IMAGE)
	@echo "$(GREEN)✓ Scan complete$(NC)"

scan-json: ## Scan and output JSON report
	@echo "$(CYAN)Scanning image (JSON): $(IMAGE)$(NC)"
	trivy image --format json --output trivy-report.json $(IMAGE)
	@echo "$(GREEN)✓ Report saved to trivy-report.json$(NC)"

scan-docker: ## Use Docker Scout for scanning (if available)
	@echo "$(CYAN)Scanning with Docker Scout: $(IMAGE)$(NC)"
	docker scout cves $(IMAGE) || echo "Docker Scout not available"

# =====================================================================
# IMAGE MANAGEMENT
# =====================================================================

push: build ## Build and push image to registry
	@echo "$(CYAN)Pushing image to registry: $(IMAGE)$(NC)"
	docker push $(IMAGE)
	docker push $(LATEST)
	@echo "$(GREEN)✓ Push complete$(NC)"

pull: ## Pull image from registry
	@echo "$(CYAN)Pulling image: $(IMAGE)$(NC)"
	docker pull $(IMAGE)
	@echo "$(GREEN)✓ Pull complete$(NC)"

tag: build ## Tag image with version
	@echo "$(CYAN)Tagging image as $(LATEST)$(NC)"
	docker tag $(IMAGE) $(LATEST)
	@echo "$(GREEN)✓ Tagging complete$(NC)"

inspect: ## Inspect image structure
	@echo "$(CYAN)Image information: $(IMAGE)$(NC)"
	docker inspect $(IMAGE) | jq '.[] | {Architecture, Os, RootFS}'

size: ## Show image size and layers
	@echo "$(CYAN)Image size breakdown: $(IMAGE)$(NC)"
	docker history $(IMAGE) --human=true --no-trunc

history: ## Show detailed image history
	docker history $(IMAGE)

# =====================================================================
# CLEANUP
# =====================================================================

clean: ## Remove built images
	@echo "$(RED)Removing images$(NC)"
	docker rmi -f $(IMAGE) $(LATEST) || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

prune: ## Prune unused Docker resources
	@echo "$(RED)Pruning Docker resources$(NC)"
	docker system prune -af
	@echo "$(GREEN)✓ Prune complete$(NC)"

prune-volumes: ## Prune unused volumes
	@echo "$(RED)Pruning volumes$(NC)"
	docker volume prune -f
	@echo "$(GREEN)✓ Volume prune complete$(NC)"

logs: ## View container logs
	docker logs -f $(APP_NAME) || echo "Container not running"

stop: ## Stop running container
	@echo "$(CYAN)Stopping container: $(APP_NAME)$(NC)"
	docker stop $(APP_NAME) || true
	@echo "$(GREEN)✓ Container stopped$(NC)"

rm: ## Remove container
	@echo "$(RED)Removing container: $(APP_NAME)$(NC)"
	docker rm -f $(APP_NAME) || true
	@echo "$(GREEN)✓ Container removed$(NC)"

# =====================================================================
# DEBUGGING
# =====================================================================

shell: ## Open shell in running container
	docker exec -it $(APP_NAME) /bin/sh

shell-build: ## Open shell in builder stage
	docker run --rm -it --entrypoint sh $(IMAGE) as builder

stats: ## Show container resource usage
	docker stats

env: ## Show environment variables in image
	@echo "$(CYAN)Environment variables in $(IMAGE)$(NC)"
	docker run --rm $(IMAGE) env | sort

whoami: ## Check user in container
	@echo "$(CYAN)Running user in $(IMAGE)$(NC)"
	docker run --rm $(IMAGE) whoami

# =====================================================================
# DOCKER COMPOSE HELPERS
# =====================================================================

compose-ps: ## Show service status
	docker-compose ps

compose-db-shell: ## Connect to database shell
	docker-compose exec postgres psql -U appuser -d appdb

compose-redis-shell: ## Connect to redis shell
	docker-compose exec redis redis-cli

compose-rebuild: ## Rebuild services
	@echo "$(CYAN)Rebuilding services$(NC)"
	docker-compose down -v
	docker-compose up -d --build
	@echo "$(GREEN)✓ Rebuild complete$(NC)"

compose-validate: ## Validate docker-compose file
	@echo "$(CYAN)Validating docker-compose.yml$(NC)"
	docker-compose config > /dev/null && echo "$(GREEN)✓ Valid$(NC)" || echo "$(RED)✗ Invalid$(NC)"

.DEFAULT_GOAL := help
