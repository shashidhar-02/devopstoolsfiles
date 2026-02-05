#!/usr/bin/env bash
# =============================================================================
# WORKSPACE MANAGEMENT SCRIPT
# =============================================================================
# Manage Terraform workspaces and environment switching
# Usage: ./workspace-setup.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# WORKSPACE OPERATIONS
# =============================================================================

list_workspaces() {
    log_info "Available workspaces:"
    terraform workspace list
}

create_workspace() {
    local workspace=$1
    
    log_info "Creating workspace: $workspace"
    terraform workspace new "$workspace"
    log_info "Workspace '$workspace' created successfully"
}

select_workspace() {
    local workspace=$1
    
    log_info "Selecting workspace: $workspace"
    terraform workspace select "$workspace"
    log_info "Current workspace: $(terraform workspace show)"
}

delete_workspace() {
    local workspace=$1
    
    log_warn "⚠️  WARNING: This will delete workspace '$workspace'"
    read -p "Are you sure? (yes/no): " -r
    
    if [[ $REPLY != "yes" ]]; then
        log_info "Deletion cancelled"
        return 0
    fi
    
    # Cannot delete current workspace, switch first
    local current=$(terraform workspace show)
    if [[ "$current" == "$workspace" ]]; then
        log_info "Switching to default workspace first..."
        terraform workspace select default
    fi
    
    terraform workspace delete "$workspace"
    log_info "Workspace '$workspace' deleted"
}

# =============================================================================
# ENVIRONMENT SETUP
# =============================================================================

setup_environment() {
    local env=$1
    
    log_info "Setting up environment: $env"
    
    # Check if environment config exists
    if [[ ! -d "environments/$env" ]]; then
        log_error "Environment directory not found: environments/$env"
        return 1
    fi
    
    if [[ ! -f "environments/$env/terraform.tfvars" ]]; then
        log_error "Variables file not found: environments/$env/terraform.tfvars"
        return 1
    fi
    
    # Create or select workspace
    if terraform workspace list | grep -q "$env"; then
        select_workspace "$env"
    else
        create_workspace "$env"
    fi
    
    log_info "Environment '$env' is ready"
    echo ""
    log_info "Next steps:"
    echo "  1. Review configuration: cat environments/$env/terraform.tfvars"
    echo "  2. Plan changes: terraform plan -var-file=environments/$env/terraform.tfvars"
    echo "  3. Apply changes: terraform apply -var-file=environments/$env/terraform.tfvars"
}

# =============================================================================
# WORKSPACE vs ENVIRONMENT FOLDERS COMPARISON
# =============================================================================

show_comparison() {
    cat << 'EOF'

==================== WORKSPACES vs ENVIRONMENT FOLDERS ====================

TERRAFORM WORKSPACES:
---------------------
Pros:
  ✓ Single codebase
  ✓ Easy switching (terraform workspace select <env>)
  ✓ Same backend configuration
  ✓ Shared modules and configurations

Cons:
  ✗ Easy to apply to wrong workspace
  ✗ All workspaces in same state backend
  ✗ Harder to have different backend configs per env

Usage:
  terraform workspace new dev
  terraform workspace select dev
  terraform apply -var-file=environments/dev/terraform.tfvars

---------------------
ENVIRONMENT FOLDERS:
---------------------
Pros:
  ✓ Complete isolation between environments
  ✓ Different backend configs per environment
  ✓ No accidental cross-environment changes
  ✓ Clearer separation of concerns

Cons:
  ✗ Code duplication (need separate directories)
  ✗ More directory navigation
  ✗ Need to manage multiple state backends

Structure:
  environments/
    ├── dev/
    │   ├── main.tf -> ../../main.tf (symlink)
    │   ├── backend.tf
    │   └── terraform.tfvars
    ├── staging/
    └── prod/

RECOMMENDATION:
---------------
For Enterprise/Production:
  → Use ENVIRONMENT FOLDERS for complete isolation
  → Separate AWS accounts per environment
  → Different state backends per environment
  → CI/CD pipelines per environment

For Development/Testing:
  → Use WORKSPACES for quick switching
  → Shared development account
  → Single state backend
  → Fast iteration

HYBRID APPROACH (BEST):
----------------------
  → Environment folders for prod/staging (isolation)
  → Workspaces within dev environment (flexibility)
  → Separate AWS accounts: prod, staging, dev
  → Different state backends for prod/staging
  → Workspaces in dev for feature testing

===========================================================================

EOF
}

# =============================================================================
# WORKSPACE MIGRATION
# =============================================================================

migrate_to_folders() {
    log_info "Migrating from workspaces to environment folders..."
    
    local workspaces=(dev staging prod)
    
    for env in "${workspaces[@]}"; do
        log_info "Processing workspace: $env"
        
        # Create environment directory structure
        mkdir -p "environments/$env/.terraform"
        
        # Pull workspace state
        terraform workspace select "$env"
        terraform state pull > "environments/$env/terraform.tfstate"
        
        # Create symlinks to main files
        ln -sf ../../main.tf "environments/$env/main.tf"
        ln -sf ../../variables.tf "environments/$env/variables.tf"
        ln -sf ../../outputs.tf "environments/$env/outputs.tf"
        ln -sf ../../providers.tf "environments/$env/providers.tf"
        ln -sf ../../modules "environments/$env/modules"
        
        log_info "Environment folder created for: $env"
    done
    
    log_info "Migration completed!"
    log_warn "Review the environment directories before committing"
}

# =============================================================================
# MENU
# =============================================================================

show_menu() {
    clear
    echo "=========================================="
    echo "   TERRAFORM WORKSPACE MANAGEMENT"
    echo "=========================================="
    echo ""
    echo "Current workspace: $(terraform workspace show 2>/dev/null || echo 'Not initialized')"
    echo ""
    echo "1. List workspaces"
    echo "2. Create workspace"
    echo "3. Select workspace"
    echo "4. Delete workspace"
    echo "5. Setup environment (create/select + validate)"
    echo "6. Show workspaces vs folders comparison"
    echo "7. Migrate to environment folders"
    echo "8. Exit"
    echo ""
}

main() {
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed"
        exit 1
    fi
    
    # Check if in terraform directory
    if [[ ! -f "main.tf" ]]; then
        log_error "Not in a Terraform directory (main.tf not found)"
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "Select an option (1-8): " choice
        
        case $choice in
            1)
                list_workspaces
                read -p "Press Enter to continue..."
                ;;
            2)
                read -p "Enter workspace name: " workspace
                create_workspace "$workspace"
                read -p "Press Enter to continue..."
                ;;
            3)
                read -p "Enter workspace name: " workspace
                select_workspace "$workspace"
                read -p "Press Enter to continue..."
                ;;
            4)
                read -p "Enter workspace name to delete: " workspace
                delete_workspace "$workspace"
                read -p "Press Enter to continue..."
                ;;
            5)
                read -p "Enter environment (dev/staging/prod): " env
                setup_environment "$env"
                read -p "Press Enter to continue..."
                ;;
            6)
                show_comparison
                read -p "Press Enter to continue..."
                ;;
            7)
                migrate_to_folders
                read -p "Press Enter to continue..."
                ;;
            8)
                log_info "Exiting..."
                exit 0
                ;;
            *)
                log_error "Invalid option"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
