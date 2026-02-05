# =============================================================================
# TERRAFORM PROVIDERS CONFIGURATION
# =============================================================================
# Multi-region provider setup for enterprise environments

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Primary AWS Provider (us-east-1)
provider "aws" {
  region = var.primary_region
  
  default_tags {
    tags = {
      Environment   = var.environment
      ManagedBy     = "Terraform"
      Project       = var.project_name
      CostCenter    = var.cost_center
      Owner         = var.owner
      Compliance    = var.compliance_level
    }
  }
  
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = "terraform-${var.environment}"
  }
}

# Secondary AWS Provider for DR (us-west-2)
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
  
  default_tags {
    tags = {
      Environment   = var.environment
      ManagedBy     = "Terraform"
      Project       = var.project_name
      CostCenter    = var.cost_center
      Owner         = var.owner
      Compliance    = var.compliance_level
      Region        = "DR"
    }
  }
  
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = "terraform-${var.environment}-dr"
  }
}

# Multi-Account Setup - Production Account
provider "aws" {
  alias  = "production"
  region = var.primary_region
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.production_account_id}:role/TerraformRole"
    session_name = "terraform-prod"
  }
}

# Multi-Account Setup - Staging Account
provider "aws" {
  alias  = "staging"
  region = var.primary_region
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.staging_account_id}:role/TerraformRole"
    session_name = "terraform-staging"
  }
}

# Multi-Account Setup - Development Account
provider "aws" {
  alias  = "dev"
  region = var.primary_region
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.dev_account_id}:role/TerraformRole"
    session_name = "terraform-dev"
  }
}
