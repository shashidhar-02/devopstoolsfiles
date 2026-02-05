# =============================================================================
# POLICY AS CODE - OPA (Open Policy Agent) EXAMPLES
# =============================================================================
# Terraform compliance policies using OPA Rego language
# Use with: conftest test

package terraform.security

# =============================================================================
# ENCRYPTION POLICIES
# =============================================================================

# Deny S3 buckets without encryption
deny[msg] {
    resource := input.resource.aws_s3_bucket[name]
    not resource.server_side_encryption_configuration
    msg := sprintf("S3 bucket '%s' must have encryption enabled", [name])
}

# Deny RDS instances without encryption
deny[msg] {
    resource := input.resource.aws_db_instance[name]
    resource.storage_encrypted == false
    msg := sprintf("RDS instance '%s' must have storage encryption enabled", [name])
}

# Deny EBS volumes without encryption
deny[msg] {
    resource := input.resource.aws_ebs_volume[name]
    not resource.encrypted
    msg := sprintf("EBS volume '%s' must be encrypted", [name])
}

# =============================================================================
# NETWORK SECURITY POLICIES
# =============================================================================

# Deny security groups with 0.0.0.0/0 ingress on SSH (22)
deny[msg] {
    resource := input.resource.aws_security_group[name]
    ingress := resource.ingress[_]
    ingress.from_port == 22
    ingress.cidr_blocks[_] == "0.0.0.0/0"
    msg := sprintf("Security group '%s' allows SSH from 0.0.0.0/0", [name])
}

# Deny security groups with 0.0.0.0/0 ingress on RDP (3389)
deny[msg] {
    resource := input.resource.aws_security_group[name]
    ingress := resource.ingress[_]
    ingress.from_port == 3389
    ingress.cidr_blocks[_] == "0.0.0.0/0"
    msg := sprintf("Security group '%s' allows RDP from 0.0.0.0/0", [name])
}

# Warn about overly permissive security groups
warn[msg] {
    resource := input.resource.aws_security_group[name]
    ingress := resource.ingress[_]
    ingress.cidr_blocks[_] == "0.0.0.0/0"
    ingress.from_port != 80
    ingress.from_port != 443
    msg := sprintf("Security group '%s' has overly permissive ingress rule", [name])
}

# =============================================================================
# PUBLIC ACCESS POLICIES
# =============================================================================

# Deny publicly accessible RDS instances
deny[msg] {
    resource := input.resource.aws_db_instance[name]
    resource.publicly_accessible == true
    msg := sprintf("RDS instance '%s' must not be publicly accessible", [name])
}

# Deny S3 buckets without public access block
deny[msg] {
    bucket := input.resource.aws_s3_bucket[name]
    not input.resource.aws_s3_bucket_public_access_block[name]
    msg := sprintf("S3 bucket '%s' must have public access block configured", [name])
}

# =============================================================================
# TAGGING POLICIES
# =============================================================================

# Mandatory tags
required_tags := ["Environment", "ManagedBy", "Project", "Owner"]

# Warn if required tags are missing
warn[msg] {
    resource := input.resource[resource_type][name]
    resource_type != "aws_s3_bucket_public_access_block"
    missing_tags := [tag | tag := required_tags[_]; not resource.tags[tag]]
    count(missing_tags) > 0
    msg := sprintf("%s '%s' is missing required tags: %v", [resource_type, name, missing_tags])
}

# =============================================================================
# BACKUP AND DISASTER RECOVERY POLICIES
# =============================================================================

# Deny RDS without backup retention for production
deny[msg] {
    resource := input.resource.aws_db_instance[name]
    contains(name, "prod")
    resource.backup_retention_period < 30
    msg := sprintf("Production RDS instance '%s' must have minimum 30 days backup retention", [name])
}

# Deny production RDS without Multi-AZ
deny[msg] {
    resource := input.resource.aws_db_instance[name]
    contains(name, "prod")
    resource.multi_az == false
    msg := sprintf("Production RDS instance '%s' must have Multi-AZ enabled", [name])
}

# =============================================================================
# COMPLIANCE POLICIES
# =============================================================================

# Deny resources without deletion protection in production
deny[msg] {
    resource := input.resource.aws_db_instance[name]
    contains(name, "prod")
    resource.deletion_protection == false
    msg := sprintf("Production RDS instance '%s' must have deletion protection enabled", [name])
}

# Warn about resources in non-approved regions
approved_regions := ["us-east-1", "us-west-2", "eu-west-1"]

warn[msg] {
    provider := input.provider.aws[name]
    region := provider.region
    not region_approved(region)
    msg := sprintf("Provider '%s' uses non-approved region: %s", [name, region])
}

region_approved(region) {
    region == approved_regions[_]
}

# =============================================================================
# COST OPTIMIZATION POLICIES
# =============================================================================

# Warn about expensive instance types in non-production
expensive_instances := ["c5.4xlarge", "c5.9xlarge", "c5.18xlarge", "r5.8xlarge"]

warn[msg] {
    resource := input.resource.aws_instance[name]
    not contains(name, "prod")
    resource.instance_type == expensive_instances[_]
    msg := sprintf("Instance '%s' uses expensive instance type %s in non-production", [name, resource.instance_type])
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

contains(str, substr) {
    contains(lower(str), lower(substr))
}
