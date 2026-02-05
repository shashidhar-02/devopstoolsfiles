# =============================================================================
# EC2 MODULE - Main Configuration
# =============================================================================

resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  user_data              = var.user_data
  
  monitoring = true
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  
  dynamic "root_block_device" {
    for_each = length(var.root_block_device) > 0 ? [var.root_block_device] : []
    
    content {
      volume_type           = lookup(root_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(root_block_device.value, "volume_size", 50)
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
