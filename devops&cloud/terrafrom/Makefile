# =============================================================================
# MAKEFILE FOR TERRAFORM OPERATIONS
# =============================================================================
# Common Terraform commands for easier workflow
# Usage: make <target> ENV=<dev|staging|prod>

.PHONY: help init plan apply destroy validate fmt lint clean import

# Default environment
ENV ?= dev

# Variables
VARS_FILE := environments/$(ENV)/terraform.tfvars
PLAN_FILE := $(ENV).tfplan

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

##@ General

help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\n$(GREEN)Usage:$(NC)\n  make $(YELLOW)<target>$(NC) ENV=$(YELLOW)<env>$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Terraform Lifecycle

init: ## Initialize Terraform
	@echo "$(GREEN)Initializing Terraform...$(NC)"
	terraform init

workspace: ## Select or create workspace
	@echo "$(GREEN)Selecting workspace: $(ENV)$(NC)"
	terraform workspace select $(ENV) || terraform workspace new $(ENV)

plan: workspace ## Generate execution plan
	@echo "$(GREEN)Planning infrastructure for $(ENV)...$(NC)"
	terraform plan -var-file=$(VARS_FILE) -out=$(PLAN_FILE)

apply: ## Apply changes
	@echo "$(YELLOW)Applying infrastructure changes for $(ENV)...$(NC)"
	@if [ -f $(PLAN_FILE) ]; then \
		terraform apply $(PLAN_FILE); \
	else \
		terraform apply -var-file=$(VARS_FILE); \
	fi

destroy: workspace ## Destroy infrastructure
	@echo "$(RED)WARNING: This will destroy all resources in $(ENV)!$(NC)"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ]
	terraform destroy -var-file=$(VARS_FILE)

##@ Code Quality

validate: ## Validate Terraform configuration
	@echo "$(GREEN)Validating configuration...$(NC)"
	terraform validate

fmt: ## Format Terraform files
	@echo "$(GREEN)Formatting Terraform files...$(NC)"
	terraform fmt -recursive

lint: ## Lint with tflint
	@echo "$(GREEN)Running tflint...$(NC)"
	@if command -v tflint > /dev/null; then \
		tflint --init; \
		tflint; \
	else \
		echo "$(YELLOW)tflint not installed. Skipping...$(NC)"; \
	fi

security: ## Run security checks with tfsec
	@echo "$(GREEN)Running security checks...$(NC)"
	@if command -v tfsec > /dev/null; then \
		tfsec .; \
	else \
		echo "$(YELLOW)tfsec not installed. Skipping...$(NC)"; \
	fi

##@ Policy

policy-opa: ## Test OPA policies
	@echo "$(GREEN)Testing OPA policies...$(NC)"
	@if command -v conftest > /dev/null; then \
		terraform plan -var-file=$(VARS_FILE) -out=tfplan.binary; \
		terraform show -json tfplan.binary > tfplan.json; \
		conftest test tfplan.json -p policies/opa/; \
		rm -f tfplan.binary tfplan.json; \
	else \
		echo "$(YELLOW)conftest not installed. Skipping...$(NC)"; \
	fi

##@ State Management

state-list: workspace ## List resources in state
	@echo "$(GREEN)Listing resources in state...$(NC)"
	terraform state list

state-show: workspace ## Show specific resource
	@read -p "Enter resource address: " resource && \
	terraform state show "$$resource"

state-pull: workspace ## Pull current state
	@echo "$(GREEN)Pulling current state...$(NC)"
	terraform state pull > state-$(ENV)-$(shell date +%Y%m%d-%H%M%S).tfstate

state-push: ## Push state file
	@read -p "Enter state file path: " statefile && \
	terraform state push "$$statefile"

unlock: ## Force unlock state
	@read -p "Enter Lock ID: " lockid && \
	terraform force-unlock -force "$$lockid"

##@ Utilities

graph: ## Generate dependency graph
	@echo "$(GREEN)Generating dependency graph...$(NC)"
	terraform graph | dot -Tpng > infrastructure-graph.png
	@echo "$(GREEN)Graph saved to infrastructure-graph.png$(NC)"

output: workspace ## Show outputs
	@echo "$(GREEN)Showing outputs for $(ENV)...$(NC)"
	terraform output

refresh: workspace ## Refresh state
	@echo "$(GREEN)Refreshing state for $(ENV)...$(NC)"
	terraform refresh -var-file=$(VARS_FILE)

import: workspace ## Import existing resource
	@echo "$(GREEN)Import wizard$(NC)"
	@./scripts/import-existing.sh $(ENV)

clean: ## Clean temporary files
	@echo "$(GREEN)Cleaning temporary files...$(NC)"
	rm -f *.tfplan *.tfstate *.backup *.log
	rm -f tfplan.binary tfplan.json
	@echo "$(GREEN)Clean complete!$(NC)"

##@ Environments

dev: ## Deploy to dev
	@$(MAKE) plan ENV=dev
	@$(MAKE) apply ENV=dev

staging: ## Deploy to staging
	@$(MAKE) plan ENV=staging
	@read -p "Review plan, then press Enter to apply..." && \
	$(MAKE) apply ENV=staging

prod: ## Deploy to production
	@echo "$(RED)PRODUCTION DEPLOYMENT$(NC)"
	@$(MAKE) plan ENV=prod
	@read -p "$(RED)Carefully review plan! Press Enter to continue or Ctrl+C to cancel...$(NC)" && \
	$(MAKE) apply ENV=prod

##@ Full Workflow

check: validate fmt lint security ## Run all checks

ci: init validate fmt lint security ## CI pipeline tasks
	@echo "$(GREEN)CI checks completed!$(NC)"

deploy: init plan apply ## Complete deployment workflow
	@echo "$(GREEN)Deployment completed for $(ENV)!$(NC)"

##@ Documentation

docs: ## Generate documentation
	@echo "$(GREEN)Generating documentation...$(NC)"
	@if command -v terraform-docs > /dev/null; then \
		terraform-docs markdown table . > TERRAFORM.md; \
		echo "$(GREEN)Documentation generated: TERRAFORM.md$(NC)"; \
	else \
		echo "$(YELLOW)terraform-docs not installed. Skipping...$(NC)"; \
	fi

costs: ## Estimate costs with Infracost
	@echo "$(GREEN)Estimating costs...$(NC)"
	@if command -v infracost > /dev/null; then \
		terraform plan -var-file=$(VARS_FILE) -out=tfplan.binary; \
		terraform show -json tfplan.binary > tfplan.json; \
		infracost breakdown --path tfplan.json; \
		rm -f tfplan.binary tfplan.json; \
	else \
		echo "$(YELLOW)infracost not installed. Skipping...$(NC)"; \
	fi

.DEFAULT_GOAL := help
