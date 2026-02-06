# =============================================================================
# S3 MODULE - Main Configuration
# =============================================================================

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  
  tags = merge(
    var.tags,
    {
      Name = var.bucket_name
    }
  )
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = length(var.server_side_encryption_configuration) > 0 ? 1 : 0
  
  bucket = aws_s3_bucket.this.id
  
  dynamic "rule" {
    for_each = [lookup(var.server_side_encryption_configuration, "rule", {})]
    
    content {
      apply_server_side_encryption_by_default {
        sse_algorithm     = lookup(rule.value.apply_server_side_encryption_by_default, "sse_algorithm", "AES256")
        kms_master_key_id = lookup(rule.value.apply_server_side_encryption_by_default, "kms_master_key_id", null)
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0
  
  bucket = aws_s3_bucket.this.id
  
  dynamic "rule" {
    for_each = var.lifecycle_rules
    
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"
      
      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])
        
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
      
      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration", null) != null ? [rule.value.expiration] : []
        
        content {
          days = expiration.value.days
        }
      }
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.this.id
  
  target_bucket = aws_s3_bucket.this.id
  target_prefix = "access-logs/"
}
