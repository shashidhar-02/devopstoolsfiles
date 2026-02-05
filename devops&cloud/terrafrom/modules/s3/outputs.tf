# =============================================================================
# S3 MODULE - Outputs
# =============================================================================

output "bucket_id" {
  description = "Bucket ID"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "Bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "regional_domain_name" {
  description = "Regional domain name"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
