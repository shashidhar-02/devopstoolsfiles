#!/usr/bin/env bash
# =============================================================================
# IMPORT EXISTING INFRASTRUCTURE SCRIPT
# =============================================================================
# This script helps import existing AWS resources into Terraform state
# Usage: ./import-existing.sh <environment>

set -euo pipefail

ENVIRONMENT=${1:-""}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate environment
if [[ -z "$ENVIRONMENT" ]]; then
    log_error "Environment not specified"
    echo "Usage: $0 <dev|staging|prod>"
    exit 1
fi

if [[ ! -d "$TERRAFORM_DIR/environments/$ENVIRONMENT" ]]; then
    log_error "Environment directory not found: environments/$ENVIRONMENT"
    exit 1
fi

log_info "Importing existing infrastructure for environment: $ENVIRONMENT"

# Change to terraform directory
cd "$TERRAFORM_DIR"

# Initialize Terraform
log_info "Initializing Terraform..."
terraform init

# Select workspace
log_info "Selecting workspace: $ENVIRONMENT"
terraform workspace select "$ENVIRONMENT" || terraform workspace new "$ENVIRONMENT"

# =============================================================================
# IMPORT VPC RESOURCES
# =============================================================================

import_vpc() {
    local vpc_id=$1
    log_info "Importing VPC: $vpc_id"
    
    terraform import \
        -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
        module.vpc.aws_vpc.this \
        "$vpc_id" || log_warn "VPC import failed or already exists"
}

import_subnets() {
    local subnet_type=$1
    local subnet_ids=("${@:2}")
    
    for i in "${!subnet_ids[@]}"; do
        log_info "Importing $subnet_type subnet [$i]: ${subnet_ids[$i]}"
        terraform import \
            -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
            "module.vpc.aws_subnet.${subnet_type}[$i]" \
            "${subnet_ids[$i]}" || log_warn "Subnet import failed or already exists"
    done
}

import_internet_gateway() {
    local igw_id=$1
    log_info "Importing Internet Gateway: $igw_id"
    
    terraform import \
        -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
        module.vpc.aws_internet_gateway.this \
        "$igw_id" || log_warn "IGW import failed or already exists"
}

import_nat_gateways() {
    local nat_ids=("$@")
    
    for i in "${!nat_ids[@]}"; do
        log_info "Importing NAT Gateway [$i]: ${nat_ids[$i]}"
        terraform import \
            -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
            "module.vpc.aws_nat_gateway.this[$i]" \
            "${nat_ids[$i]}" || log_warn "NAT Gateway import failed or already exists"
    done
}

# =============================================================================
# IMPORT EC2 RESOURCES
# =============================================================================

import_ec2_instances() {
    local service_name=$1
    local instance_id=$2
    
    log_info "Importing EC2 instance for service '$service_name': $instance_id"
    
    terraform import \
        -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
        "module.ec2_instances[\"$service_name\"].aws_instance.this" \
        "$instance_id" || log_warn "EC2 import failed or already exists"
}

# =============================================================================
# IMPORT RDS RESOURCES
# =============================================================================

import_rds() {
    local db_identifier=$1
    log_info "Importing RDS instance: $db_identifier"
    
    terraform import \
        -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
        'module.rds[0].aws_db_instance.this' \
        "$db_identifier" || log_warn "RDS import failed or already exists"
}

# =============================================================================
# IMPORT S3 RESOURCES
# =============================================================================

import_s3_buckets() {
    local bucket_type=$1
    local bucket_name=$2
    
    log_info "Importing S3 bucket '$bucket_type': $bucket_name"
    
    terraform import \
        -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
        "module.s3_buckets[\"$bucket_type\"].aws_s3_bucket.this" \
        "$bucket_name" || log_warn "S3 bucket import failed or already exists"
}

# =============================================================================
# IMPORT SECURITY GROUPS
# =============================================================================

import_security_groups() {
    local service_name=$1
    local sg_id=$2
    
    log_info "Importing Security Group for '$service_name': $sg_id"
    
    terraform import \
        -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
        "aws_security_group.dynamic_sg[\"$service_name\"]" \
        "$sg_id" || log_warn "Security Group import failed or already exists"
}

# =============================================================================
# IMPORT KMS KEYS
# =============================================================================

import_kms_keys() {
    local key_type=$1
    local key_id=$2
    
    log_info "Importing KMS key for '$key_type': $key_id"
    
    terraform import \
        -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
        "aws_kms_key.encryption_keys[\"$key_type\"]" \
        "$key_id" || log_warn "KMS key import failed or already exists"
}

# =============================================================================
# INTERACTIVE MODE
# =============================================================================

interactive_import() {
    echo ""
    echo "==================== TERRAFORM IMPORT WIZARD ===================="
    echo ""
    
    # VPC Import
    read -p "Do you want to import a VPC? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter VPC ID (e.g., vpc-12345678): " vpc_id
        import_vpc "$vpc_id"
    fi
    
    # EC2 Import
    read -p "Do you want to import EC2 instances? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter service name (web/api/worker): " service_name
        read -p "Enter instance ID (e.g., i-1234567890abcdef0): " instance_id
        import_ec2_instances "$service_name" "$instance_id"
    fi
    
    # RDS Import
    read -p "Do you want to import an RDS instance? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter RDS identifier: " db_identifier
        import_rds "$db_identifier"
    fi
    
    # S3 Import
    read -p "Do you want to import S3 buckets? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter bucket type (data/logs/backups): " bucket_type
        read -p "Enter bucket name: " bucket_name
        import_s3_buckets "$bucket_type" "$bucket_name"
    fi
    
    # Security Groups
    read -p "Do you want to import Security Groups? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter service name (web/api/worker): " service_name
        read -p "Enter Security Group ID (e.g., sg-12345678): " sg_id
        import_security_groups "$service_name" "$sg_id"
    fi
    
    # KMS Keys
    read -p "Do you want to import KMS keys? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter key type (s3/rds/secrets/ebs): " key_type
        read -p "Enter KMS Key ID: " key_id
        import_kms_keys "$key_type" "$key_id"
    fi
    
    echo ""
    log_info "Import process completed!"
    echo ""
    log_info "Next steps:"
    echo "1. Run 'terraform plan' to verify imports"
    echo "2. Adjust configuration to match existing resources"
    echo "3. Run 'terraform apply' to bring state fully in sync"
    echo ""
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Run interactive import
interactive_import

# Optional: Run plan to see what needs to be adjusted
read -p "Do you want to run 'terraform plan' now? (y/n): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Running terraform plan..."
    terraform plan -var-file="environments/$ENVIRONMENT/terraform.tfvars"
fi
