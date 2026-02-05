# =============================================================================
# RDS MODULE - Main Configuration
# =============================================================================

resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  allocated_storage     = var.allocated_storage
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id
  storage_type          = "gp3"
  
  db_name  = var.db_name
  username = var.username
  password = var.password
  
  multi_az               = var.multi_az
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = false
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true
  
  performance_insights_enabled    = true
  performance_insights_retention_period = 7
  
  tags = merge(
    var.tags,
    {
      Name = var.identifier
    }
  )
}
