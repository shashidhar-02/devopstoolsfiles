# =============================================================================
# IAM MODULE - Outputs
# =============================================================================

output "role_arns" {
  description = "Map of IAM role ARNs"
  value       = { for k, v in aws_iam_role.this : k => v.arn }
}

output "role_names" {
  description = "Map of IAM role names"
  value       = { for k, v in aws_iam_role.this : k => v.name }
}

output "instance_profiles" {
  description = "Map of instance profile names"
  value       = { for k, v in aws_iam_instance_profile.this : k => v.name }
}
