# =============================================================================
# RDS MODULE - Outputs
# =============================================================================

output "endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.endpoint
}

output "arn" {
  description = "RDS ARN"
  value       = aws_db_instance.this.arn
}

output "address" {
  description = "RDS address"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "backup_window" {
  description = "Backup window"
  value       = aws_db_instance.this.backup_window
}
