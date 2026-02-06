# =============================================================================
# TERRAFORM VARIABLES
# =============================================================================
# Enterprise-level variable definitions

# -----------------------------------------------------------------------------
# Environment Configuration
# -----------------------------------------------------------------------------
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "enterprise-platform"
}

variable "cost_center" {
  description = "Cost center for billing and chargeback"
  type        = string
}

variable "owner" {
  description = "Team or individual responsible for resources"
  type        = string
}

variable "compliance_level" {
  description = "Compliance level (PCI, HIPAA, SOC2, etc.)"
  type        = string
  default     = "standard"
}

# -----------------------------------------------------------------------------
# Multi-Region Configuration
# -----------------------------------------------------------------------------
variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region for DR"
  type        = string
  default     = "us-west-2"
}

variable "enabled_regions" {
  description = "List of regions to deploy resources"
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "eu-west-1"]
}

# -----------------------------------------------------------------------------
# Multi-Account Configuration
# -----------------------------------------------------------------------------
variable "assume_role_arn" {
  description = "IAM role ARN to assume for Terraform operations"
  type        = string
  default     = ""
}

variable "production_account_id" {
  description = "AWS Account ID for production"
  type        = string
  sensitive   = true
}

variable "staging_account_id" {
  description = "AWS Account ID for staging"
  type        = string
  sensitive   = true
}

variable "dev_account_id" {
  description = "AWS Account ID for development"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Compute Configuration
# -----------------------------------------------------------------------------
variable "instance_types" {
  description = "Map of instance types per environment"
  type        = map(string)
  default = {
    dev     = "t3.small"
    staging = "t3.medium"
    prod    = "t3.large"
  }
}

variable "desired_capacity" {
  description = "Desired capacity for Auto Scaling Group"
  type        = map(number)
  default = {
    dev     = 1
    staging = 2
    prod    = 3
  }
}

variable "min_size" {
  description = "Minimum size for Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size for Auto Scaling Group"
  type        = number
  default     = 10
}

# -----------------------------------------------------------------------------
# Database Configuration
# -----------------------------------------------------------------------------
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.3"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS (GB)"
  type        = number
  default     = 100
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = true
}

variable "db_backup_retention_period" {
  description = "Backup retention period (days)"
  type        = number
  default     = 30
}

# -----------------------------------------------------------------------------
# Secrets Management
# -----------------------------------------------------------------------------
variable "secrets_manager_kms_key_id" {
  description = "KMS key ID for Secrets Manager encryption"
  type        = string
  default     = ""
}

variable "enable_secrets_rotation" {
  description = "Enable automatic secrets rotation"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------
variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "enable_encryption" {
  description = "Enable encryption for resources"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Monitoring & Logging
# -----------------------------------------------------------------------------
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch Logs"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period"
  type        = number
  default     = 90
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Feature Flags (for_each, count, dynamic examples)
# -----------------------------------------------------------------------------
variable "features" {
  description = "Feature flags for conditional resource creation"
  type = object({
    enable_waf        = bool
    enable_shield     = bool
    enable_guardduty  = bool
    enable_cloudtrail = bool
    enable_config     = bool
  })
  default = {
    enable_waf        = true
    enable_shield     = false
    enable_guardduty  = true
    enable_cloudtrail = true
    enable_config     = true
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Module-specific Variables (examples)
# -----------------------------------------------------------------------------
variable "services" {
  description = "Map of services to deploy with for_each"
  type = map(object({
    enabled       = bool
    instance_type = string
    min_capacity  = number
    max_capacity  = number
  }))
  default = {
    web = {
      enabled       = true
      instance_type = "t3.medium"
      min_capacity  = 2
      max_capacity  = 10
    }
    api = {
      enabled       = true
      instance_type = "t3.large"
      min_capacity  = 3
      max_capacity  = 20
    }
    worker = {
      enabled       = true
      instance_type = "t3.small"
      min_capacity  = 1
      max_capacity  = 5
    }
  }
}
