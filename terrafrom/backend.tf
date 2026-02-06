# =============================================================================
# TERRAFORM BACKEND CONFIGURATION
# =============================================================================
# S3 + DynamoDB for remote state management with locking

terraform {
  backend "s3" {
    # State Storage
    bucket = "terraform-state-enterprise-prod"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
    
    # State Locking with DynamoDB
    dynamodb_table = "terraform-state-lock"
    
    # Encryption at rest
    encrypt = true
    kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    
    # Access Control
    acl = "private"
    
    # Workspace support
    workspace_key_prefix = "workspaces"
    
    # Additional security
    skip_credentials_validation = false
    skip_metadata_api_check     = false
    force_path_style            = false
    
    # Role assumption for cross-account access
    role_arn = "arn:aws:iam::123456789012:role/TerraformStateRole"
    
    # Session configuration
    session_name = "terraform-backend"
    
    # Enable versioning for state recovery
    # Note: Versioning must be enabled on the S3 bucket separately
  }
}

# =============================================================================
# BACKEND SETUP INSTRUCTIONS
# =============================================================================
# 
# 1. Create S3 Bucket for State:
#    aws s3api create-bucket --bucket terraform-state-enterprise-prod \
#      --region us-east-1
#
# 2. Enable Versioning (for state recovery):
#    aws s3api put-bucket-versioning --bucket terraform-state-enterprise-prod \
#      --versioning-configuration Status=Enabled
#
# 3. Enable Encryption:
#    aws s3api put-bucket-encryption --bucket terraform-state-enterprise-prod \
#      --server-side-encryption-configuration '{
#        "Rules": [{"ApplyServerSideEncryptionByDefault": 
#          {"SSEAlgorithm": "aws:kms"}}]}'
#
# 4. Block Public Access:
#    aws s3api put-public-access-block --bucket terraform-state-enterprise-prod \
#      --public-access-block-configuration \
#      BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
#
# 5. Create DynamoDB Table for Locking:
#    aws dynamodb create-table --table-name terraform-state-lock \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --billing-mode PAY_PER_REQUEST \
#      --region us-east-1
#
# 6. Enable Point-in-Time Recovery on DynamoDB:
#    aws dynamodb update-continuous-backups --table-name terraform-state-lock \
#      --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true
#
# =============================================================================
# STATE RECOVERY COMMANDS
# =============================================================================
#
# List state versions:
#   aws s3api list-object-versions --bucket terraform-state-enterprise-prod \
#     --prefix infra/terraform.tfstate
#
# Recover from specific version:
#   aws s3api get-object --bucket terraform-state-enterprise-prod \
#     --key infra/terraform.tfstate --version-id <VERSION_ID> \
#     recovered-state.tfstate
#
# Force unlock (if lock is stuck):
#   terraform force-unlock <LOCK_ID>
#
# =============================================================================
