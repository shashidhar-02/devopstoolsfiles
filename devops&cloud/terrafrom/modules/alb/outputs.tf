# =============================================================================
# ALB MODULE - Outputs
# =============================================================================

output "arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "target_group_arns" {
  description = "Target group ARNs"
  value       = [aws_lb_target_group.this.arn]
}
