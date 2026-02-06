# =============================================================================
# IAM MODULE - Main Configuration
# =============================================================================

# IAM Roles
resource "aws_iam_role" "this" {
  for_each = var.roles
  
  name = "${var.name_prefix}-${each.key}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = each.value.service
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-${each.key}"
    }
  )
}

# Attach managed policies
resource "aws_iam_role_policy_attachment" "this" {
  for_each = merge([
    for role_key, role in var.roles : {
      for policy in role.policies :
      "${role_key}-${basename(policy)}" => {
        role       = role_key
        policy_arn = policy
      }
    }
  ]...)
  
  role       = aws_iam_role.this[each.value.role].name
  policy_arn = each.value.policy_arn
}

# Instance profiles for EC2
resource "aws_iam_instance_profile" "this" {
  for_each = { for k, v in var.roles : k => v if v.service == "ec2.amazonaws.com" }
  
  name = "${var.name_prefix}-${each.key}-profile"
  role = aws_iam_role.this[each.key].name
  
  tags = var.tags
}

# Custom policies
resource "aws_iam_policy" "s3_access" {
  name        = "${var.name_prefix}-s3-access"
  description = "Policy for S3 access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-*/*",
          "arn:aws:s3:::${var.name_prefix}-*"
        ]
      }
    ]
  })
  
  tags = var.tags
}
