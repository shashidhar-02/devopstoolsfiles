# =============================================================================
# TERRAFORM OUTPUTS
# =============================================================================
# Outputs for resource references and cross-stack dependencies

# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

# -----------------------------------------------------------------------------
# Compute Outputs
# -----------------------------------------------------------------------------
output "ec2_instances" {
  description = "Map of EC2 instance details"
  value = {
    for k, v in module.ec2_instances : k => {
      id         = v.instance_id
      private_ip = v.private_ip
      public_ip  = v.public_ip
    }
  }
}

output "autoscaling_group_names" {
  description = "Auto Scaling Group names"
  value       = { for k, v in module.asg : k => v.asg_name }
}

output "load_balancer_dns" {
  description = "Load Balancer DNS names"
  value       = { for k, v in module.alb : k => v.dns_name }
  sensitive   = false
}

# -----------------------------------------------------------------------------
# Database Outputs
# -----------------------------------------------------------------------------
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = try(module.rds[0].endpoint, "")
  sensitive   = true
}

output "rds_arn" {
  description = "RDS ARN"
  value       = try(module.rds[0].arn, "")
}

output "rds_backup_window" {
  description = "RDS backup window"
  value       = try(module.rds[0].backup_window, "")
}

# -----------------------------------------------------------------------------
# Storage Outputs
# -----------------------------------------------------------------------------
output "s3_buckets" {
  description = "Map of S3 bucket details"
  value = {
    for k, v in module.s3_buckets : k => {
      id  = v.bucket_id
      arn = v.bucket_arn
    }
  }
}

output "s3_bucket_regional_domain_names" {
  description = "S3 bucket regional domain names"
  value       = { for k, v in module.s3_buckets : k => v.regional_domain_name }
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------
output "security_group_ids" {
  description = "Map of security group IDs"
  value = {
    for k, v in aws_security_group.dynamic_sg : k => v.id
  }
}

output "iam_role_arns" {
  description = "Map of IAM role ARNs"
  value       = module.iam.role_arns
  sensitive   = true
}

output "kms_key_ids" {
  description = "Map of KMS key IDs"
  value = {
    for k, v in aws_kms_key.encryption_keys : k => v.id
  }
  sensitive = true
}

# -----------------------------------------------------------------------------
# Secrets Outputs
# -----------------------------------------------------------------------------
output "secrets_manager_arns" {
  description = "Secrets Manager secret ARNs"
  value = {
    for k, v in aws_secretsmanager_secret.secrets : k => v.arn
  }
  sensitive = true
}

# -----------------------------------------------------------------------------
# Monitoring Outputs
# -----------------------------------------------------------------------------
output "cloudwatch_log_groups" {
  description = "CloudWatch Log Group names"
  value       = { for k, v in aws_cloudwatch_log_group.logs : k => v.name }
}

output "sns_topic_arns" {
  description = "SNS Topic ARNs for notifications"
  value       = { for k, v in aws_sns_topic.alerts : k => v.arn }
}

# -----------------------------------------------------------------------------
# Multi-Region Outputs
# -----------------------------------------------------------------------------
output "primary_region_resources" {
  description = "Resources deployed in primary region"
  value = {
    region = var.primary_region
    vpc_id = module.vpc.vpc_id
  }
}

output "secondary_region_resources" {
  description = "Resources deployed in secondary region (DR)"
  value = {
    region = var.secondary_region
    vpc_id = try(module.vpc_dr[0].vpc_id, "")
  }
}

# -----------------------------------------------------------------------------
# Dependency Graph Output (for visualization)
# -----------------------------------------------------------------------------
output "resource_dependencies" {
  description = "Resource dependency map for documentation"
  value = {
    vpc_depends_on        = ["aws_kms_key.encryption_keys"]
    rds_depends_on        = ["module.vpc", "aws_security_group.dynamic_sg"]
    ec2_depends_on        = ["module.vpc", "module.iam"]
    s3_depends_on         = ["aws_kms_key.encryption_keys"]
    monitoring_depends_on = ["module.vpc", "module.ec2_instances"]
  }
}

# -----------------------------------------------------------------------------
# Cost Estimation Outputs
# -----------------------------------------------------------------------------
output "resource_counts" {
  description = "Resource counts for cost estimation"
  value = {
    vpc_count              = 1
    subnet_count           = length(module.vpc.private_subnet_ids) + length(module.vpc.public_subnet_ids)
    nat_gateway_count      = length(module.vpc.nat_gateway_ids)
    ec2_instance_count     = length(module.ec2_instances)
    rds_instance_count     = var.db_multi_az ? 2 : 1
    s3_bucket_count        = length(module.s3_buckets)
    load_balancer_count    = length(module.alb)
    security_group_count   = length(aws_security_group.dynamic_sg)
    kms_key_count          = length(aws_kms_key.encryption_keys)
  }
}

# -----------------------------------------------------------------------------
# Environment Information
# -----------------------------------------------------------------------------
output "environment_info" {
  description = "Environment configuration summary"
  value = {
    environment     = var.environment
    project_name    = var.project_name
    primary_region  = var.primary_region
    secondary_region = var.secondary_region
    terraform_workspace = terraform.workspace
  }
}

# -----------------------------------------------------------------------------
# Import Commands Reference
# -----------------------------------------------------------------------------
output "import_commands" {
  description = "Example import commands for existing infrastructure"
  value = {
    vpc        = "terraform import module.vpc.aws_vpc.this <vpc-id>"
    subnet     = "terraform import module.vpc.aws_subnet.private[0] <subnet-id>"
    ec2        = "terraform import 'module.ec2_instances[\"web\"].aws_instance.this' <instance-id>"
    rds        = "terraform import 'module.rds[0].aws_db_instance.this' <db-identifier>"
    s3         = "terraform import 'module.s3_buckets[\"data\"].aws_s3_bucket.this' <bucket-name>"
    kms        = "terraform import 'aws_kms_key.encryption_keys[\"s3\"]' <key-id>"
  }
}
