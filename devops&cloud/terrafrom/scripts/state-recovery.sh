#!/usr/bin/env bash
# =============================================================================
# STATE RECOVERY SCRIPT
# =============================================================================
# Recover Terraform state from S3 versioned backups
# Usage: ./state-recovery.sh

set -euo pipefail

# Configuration
STATE_BUCKET="terraform-state-enterprise-prod"
STATE_KEY="infra/terraform.tfstate"
REGION="us-east-1"
BACKUP_DIR="./state-backups"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

# Create backup directory
mkdir -p "$BACKUP_DIR"

# =============================================================================
# LIST STATE VERSIONS
# =============================================================================

list_versions() {
    log_info "Listing available state versions..."
    
    aws s3api list-object-versions \
        --bucket "$STATE_BUCKET" \
        --prefix "$STATE_KEY" \
        --region "$REGION" \
        --query 'Versions[*].[VersionId,LastModified,Size,IsLatest]' \
        --output table
}

# =============================================================================
# RECOVER SPECIFIC VERSION
# =============================================================================

recover_version() {
    local version_id=$1
    local output_file="${BACKUP_DIR}/state-${version_id}.tfstate"
    
    log_info "Recovering state version: $version_id"
    
    aws s3api get-object \
        --bucket "$STATE_BUCKET" \
        --key "$STATE_KEY" \
        --version-id "$version_id" \
        --region "$REGION" \
        "$output_file"
    
    log_info "State recovered to: $output_file"
    
    # Validate JSON
    if jq empty "$output_file" 2>/dev/null; then
        log_info "State file is valid JSON"
        
        # Show summary
        local resources_count=$(jq '.resources | length' "$output_file")
        local terraform_version=$(jq -r '.terraform_version' "$output_file")
        
        echo ""
        log_info "State Summary:"
        echo "  - Terraform Version: $terraform_version"
        echo "  - Resources Count: $resources_count"
        echo ""
    else
        log_error "State file is not valid JSON!"
        return 1
    fi
}

# =============================================================================
# RESTORE STATE
# =============================================================================

restore_state() {
    local state_file=$1
    
    log_warn "⚠️  WARNING: This will replace the current Terraform state!"
    read -p "Are you sure you want to restore state from $state_file? (yes/no): " -r
    
    if [[ $REPLY != "yes" ]]; then
        log_info "Restore cancelled"
        return 0
    fi
    
    # Backup current state first
    log_info "Backing up current state..."
    terraform state pull > "${BACKUP_DIR}/current-state-backup-$(date +%Y%m%d-%H%M%S).tfstate"
    
    # Push new state
    log_info "Pushing recovered state..."
    terraform state push "$state_file"
    
    log_info "State restored successfully!"
    log_warn "Please run 'terraform plan' to verify the state"
}

# =============================================================================
# COMPARE STATES
# =============================================================================

compare_states() {
    local state1=$1
    local state2=$2
    
    log_info "Comparing states..."
    
    # Extract resource addresses
    jq -r '.resources[].module + "." + .resources[].type + "." + .resources[].name' "$state1" | sort > /tmp/state1_resources.txt
    jq -r '.resources[].module + "." + .resources[].type + "." + .resources[].name' "$state2" | sort > /tmp/state2_resources.txt
    
    echo ""
    log_info "Resources only in first state:"
    comm -23 /tmp/state1_resources.txt /tmp/state2_resources.txt
    
    echo ""
    log_info "Resources only in second state:"
    comm -13 /tmp/state1_resources.txt /tmp/state2_resources.txt
    
    echo ""
    log_info "Common resources:"
    comm -12 /tmp/state1_resources.txt /tmp/state2_resources.txt | wc -l
}

# =============================================================================
# FORCE UNLOCK STATE
# =============================================================================

force_unlock() {
    log_warn "⚠️  WARNING: Force unlocking should only be used if a lock is stuck"
    read -p "Enter Lock ID to unlock: " lock_id
    
    if [[ -z "$lock_id" ]]; then
        log_error "Lock ID cannot be empty"
        return 1
    fi
    
    log_info "Force unlocking state with Lock ID: $lock_id"
    terraform force-unlock -force "$lock_id"
}

# =============================================================================
# BACKUP CURRENT STATE
# =============================================================================

backup_current_state() {
    local backup_file="${BACKUP_DIR}/manual-backup-$(date +%Y%m%d-%H%M%S).tfstate"
    
    log_info "Backing up current state..."
    terraform state pull > "$backup_file"
    
    log_info "State backed up to: $backup_file"
}

# =============================================================================
# MAIN MENU
# =============================================================================

show_menu() {
    clear
    echo "=========================================="
    echo "   TERRAFORM STATE RECOVERY TOOL"
    echo "=========================================="
    echo ""
    echo "1. List available state versions"
    echo "2. Recover specific version"
    echo "3. Restore state from file"
    echo "4. Compare two state files"
    echo "5. Force unlock state"
    echo "6. Backup current state"
    echo "7. Exit"
    echo ""
}

main() {
    while true; do
        show_menu
        read -p "Select an option (1-7): " choice
        
        case $choice in
            1)
                list_versions
                read -p "Press Enter to continue..."
                ;;
            2)
                read -p "Enter Version ID: " version_id
                recover_version "$version_id"
                read -p "Press Enter to continue..."
                ;;
            3)
                read -p "Enter state file path: " state_file
                restore_state "$state_file"
                read -p "Press Enter to continue..."
                ;;
            4)
                read -p "Enter first state file: " state1
                read -p "Enter second state file: " state2
                compare_states "$state1" "$state2"
                read -p "Press Enter to continue..."
                ;;
            5)
                force_unlock
                read -p "Press Enter to continue..."
                ;;
            6)
                backup_current_state
                read -p "Press Enter to continue..."
                ;;
            7)
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

# Run main menu
main
