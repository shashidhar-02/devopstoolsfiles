# =============================================================================
# ENTERPRISE TERRAFORM MAIN CONFIGURATION
# =============================================================================
# Demonstrates: modules, for_each, count, dynamic blocks, dependency graphs,
# remote state, multi-region, workspaces, import, and secrets handling

# =============================================================================
# DATA SOURCES
# =============================================================================

# Current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Available AZs in current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Existing resources for import scenarios
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Remote state from other workspaces/stacks
data "terraform_remote_state" "network" {
  backend = "s3"
  
  config = {
    bucket = "terraform-state-enterprise-prod"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Secrets from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_master_password.id
  
  depends_on = [aws_secretsmanager_secret_version.db_master_password]
}

# =============================================================================
# LOCAL VALUES
# =============================================================================

locals {
  # Environment-specific configurations
  env_config = {
    dev = {
      instance_count = 1
      db_size       = "db.t3.small"
      multi_az      = false
    }
    staging = {
      instance_count = 2
      db_size       = "db.t3.medium"
      multi_az      = true
    }
    prod = {
      instance_count = 3
      db_size       = "db.t3.large"
      multi_az      = true
    }
  }
  
  current_env = local.env_config[var.environment]
  
  # Common tags merged with additional tags
  common_tags = merge(
    {
      Environment   = var.environment
      ManagedBy     = "Terraform"
      Project       = var.project_name
      Workspace     = terraform.workspace
      CostCenter    = var.cost_center
      Owner         = var.owner
    },
    var.additional_tags
  )
  
  # Service filtering using for_each
  enabled_services = {
    for k, v in var.services : k => v if v.enabled
  }
  
  # Resource naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Multi-region bucket names
  regional_buckets = [
    for region in var.enabled_regions : {
      name   = "${local.name_prefix}-${region}"
      region = region
    }
  ]
}

# =============================================================================
# KMS ENCRYPTION KEYS
# =============================================================================

# KMS keys for different services (for_each example)
resource "aws_kms_key" "encryption_keys" {
  for_each = toset(["s3", "rds", "secrets", "ebs"])
  
  description             = "KMS key for ${each.key} encryption"
  deletion_window_in_days = var.environment == "prod" ? 30 : 7
  enable_key_rotation     = true
  
  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-${each.key}-kms"
      Service = each.key
    }
  )
}

resource "aws_kms_alias" "encryption_key_aliases" {
  for_each = aws_kms_key.encryption_keys
  
  name          = "alias/${local.name_prefix}-${each.key}"
  target_key_id = each.value.key_id
}

# =============================================================================
# SECRETS MANAGEMENT
# =============================================================================

# Generate random passwords
resource "random_password" "db_master_password" {
  length  = 32
  special = true
}

resource "random_password" "api_keys" {
  for_each = local.enabled_services
  
  length  = 64
  special = false
}

# Store secrets in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_master_password" {
  name                    = "${local.name_prefix}-db-master-password"
  kms_key_id              = aws_kms_key.encryption_keys["secrets"].id
  recovery_window_in_days = var.environment == "prod" ? 30 : 7
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_master_password" {
  secret_id     = aws_secretsmanager_secret.db_master_password.id
  secret_string = random_password.db_master_password.result
}

resource "aws_secretsmanager_secret" "api_keys" {
  for_each = random_password.api_keys
  
  name                    = "${local.name_prefix}-api-key-${each.key}"
  kms_key_id              = aws_kms_key.encryption_keys["secrets"].id
  recovery_window_in_days = 7
  
  tags = merge(
    local.common_tags,
    { Service = each.key }
  )
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  for_each = aws_secretsmanager_secret.api_keys
  
  secret_id = each.value.id
  secret_string = jsonencode({
    api_key    = random_password.api_keys[each.key].result
    created_at = timestamp()
    service    = each.key
  })
}

# Secrets rotation (enterprise feature)
resource "aws_secretsmanager_secret_rotation" "db_password" {
  count = var.enable_secrets_rotation ? 1 : 0
  
  secret_id           = aws_secretsmanager_secret.db_master_password.id
  rotation_lambda_arn = aws_lambda_function.secrets_rotation[0].arn
  
  rotation_rules {
    automatically_after_days = 30
  }
}

# =============================================================================
# VPC MODULE (Reusable Infrastructure)
# =============================================================================

module "vpc" {
  source = "./modules/vpc"
  
  name               = "${local.name_prefix}-vpc"
  cidr               = var.vpc_cidr
  azs                = var.availability_zones
  private_subnets    = [for i in range(3) : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets     = [for i in range(3) : cidrsubnet(var.vpc_cidr, 8, i + 10)]
  database_subnets   = [for i in range(3) : cidrsubnet(var.vpc_cidr, 8, i + 20)]
  
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpn_gateway   = var.enable_vpn_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  enable_flow_logs                 = var.enable_flow_logs
  flow_logs_retention_in_days      = var.log_retention_days
  
  tags = local.common_tags
}

# DR VPC in secondary region (count example)
module "vpc_dr" {
  count = var.environment == "prod" ? 1 : 0
  
  source = "./modules/vpc"
  
  providers = {
    aws = aws.secondary
  }
  
  name               = "${local.name_prefix}-vpc-dr"
  cidr               = "10.1.0.0/16"
  azs                = ["${var.secondary_region}a", "${var.secondary_region}b", "${var.secondary_region}c"]
  private_subnets    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets     = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
  
  enable_nat_gateway = true
  
  tags = merge(
    local.common_tags,
    { Purpose = "Disaster Recovery" }
  )
}

# =============================================================================
# SECURITY GROUPS WITH DYNAMIC BLOCKS
# =============================================================================

# Dynamic security group rules based on configuration
resource "aws_security_group" "dynamic_sg" {
  for_each = local.enabled_services
  
  name        = "${local.name_prefix}-${each.key}-sg"
  description = "Security group for ${each.key} service"
  vpc_id      = module.vpc.vpc_id
  
  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = each.key == "web" ? [80, 443] : each.key == "api" ? [8080, 8443] : [9000]
    
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "Allow traffic on port ${ingress.value}"
    }
  }
  
  # Dynamic egress rules
  dynamic "egress" {
    for_each = var.environment == "prod" ? [443, 3306, 5432] : [0]
    
    content {
      from_port   = egress.value
      to_port     = egress.value == 0 ? 65535 : egress.value
      protocol    = egress.value == 0 ? "-1" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = egress.value == 0 ? "Allow all outbound" : "Allow outbound on ${egress.value}"
    }
  }
  
  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-${each.key}-sg"
      Service = each.key
    }
  )
}

# =============================================================================
# IAM MODULE
# =============================================================================

module "iam" {
  source = "./modules/iam"
  
  name_prefix = local.name_prefix
  environment = var.environment
  
  # Role definitions using for_each
  roles = {
    ec2_role = {
      service = "ec2.amazonaws.com"
      policies = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      ]
    }
    lambda_role = {
      service = "lambda.amazonaws.com"
      policies = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      ]
    }
    ecs_task_role = {
      service = "ecs-tasks.amazonaws.com"
      policies = []
    }
  }
  
  tags = local.common_tags
}

# =============================================================================
# EC2 INSTANCES MODULE WITH FOR_EACH
# =============================================================================

module "ec2_instances" {
  source = "./modules/ec2"
  
  for_each = local.enabled_services
  
  name                = "${local.name_prefix}-${each.key}"
  ami                 = data.aws_ami.amazon_linux_2.id
  instance_type       = each.value.instance_type
  subnet_id           = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.dynamic_sg[each.key].id]
  iam_instance_profile   = module.iam.instance_profiles["ec2_role"]
  
  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    environment  = var.environment
    service_name = each.key
    region       = var.primary_region
  })
  
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 50
    encrypted             = true
    kms_key_id            = aws_kms_key.encryption_keys["ebs"].arn
    delete_on_termination = true
  }
  
  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-${each.key}"
      Service = each.key
    }
  )
  
  depends_on = [module.vpc, module.iam]
}

# =============================================================================
# AUTO SCALING GROUPS (COUNT EXAMPLE)
# =============================================================================

module "asg" {
  source = "./modules/asg"
  
  for_each = local.enabled_services
  
  name_prefix = "${local.name_prefix}-${each.key}"
  
  min_size         = each.value.min_capacity
  max_size         = each.value.max_capacity
  desired_capacity = lookup(var.desired_capacity, var.environment, 2)
  
  vpc_zone_identifier = module.vpc.private_subnet_ids
  target_group_arns   = [module.alb[each.key].target_group_arns[0]]
  
  launch_template = {
    name          = "${local.name_prefix}-${each.key}-lt"
    image_id      = data.aws_ami.amazon_linux_2.id
    instance_type = each.value.instance_type
  }
  
  tags = local.common_tags
}

# =============================================================================
# APPLICATION LOAD BALANCER MODULE
# =============================================================================

module "alb" {
  source = "./modules/alb"
  
  for_each = { for k, v in local.enabled_services : k => v if k == "web" || k == "api" }
  
  name               = "${local.name_prefix}-${each.key}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnet_ids
  security_groups    = [aws_security_group.dynamic_sg[each.key].id]
  
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = true
  enable_cross_zone_load_balancing = true
  
  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-${each.key}-alb"
      Service = each.key
    }
  )
}

# =============================================================================
# RDS MODULE (CONDITIONAL WITH COUNT)
# =============================================================================

module "rds" {
  source = "./modules/rds"
  
  count = var.environment == "prod" || var.environment == "staging" ? 1 : 0
  
  identifier     = "${local.name_prefix}-db"
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  
  allocated_storage     = var.db_allocated_storage
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.encryption_keys["rds"].arn
  
  db_name  = "appdb"
  username = "admin"
  password = random_password.db_master_password.result
  
  multi_az               = var.db_multi_az
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [aws_security_group.dynamic_sg["api"].id]
  
  backup_retention_period = var.db_backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"
  
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  
  deletion_protection = var.enable_deletion_protection
  skip_final_snapshot = var.environment != "prod"
  
  tags = local.common_tags
  
  depends_on = [module.vpc]
}

# =============================================================================
# S3 BUCKETS MODULE WITH FOR_EACH
# =============================================================================

module "s3_buckets" {
  source = "./modules/s3"
  
  for_each = {
    data    = { versioning = true, lifecycle = true }
    logs    = { versioning = false, lifecycle = true }
    backups = { versioning = true, lifecycle = false }
  }
  
  bucket_name = "${local.name_prefix}-${each.key}"
  
  versioning_enabled = each.value.versioning
  
  lifecycle_rules = each.value.lifecycle ? [
    {
      id      = "archive-old-versions"
      enabled = true
      
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]
      
      expiration = {
        days = 365
      }
    }
  ] : []
  
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.encryption_keys["s3"].arn
      }
    }
  }
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-${each.key}"
      Purpose = each.key
    }
  )
}

# =============================================================================
# CLOUDWATCH MONITORING
# =============================================================================

resource "aws_cloudwatch_log_group" "logs" {
  for_each = local.enabled_services
  
  name              = "/aws/${var.project_name}/${var.environment}/${each.key}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.encryption_keys["secrets"].arn
  
  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-${each.key}-logs"
      Service = each.key
    }
  )
}

resource "aws_sns_topic" "alerts" {
  for_each = toset(["critical", "warning", "info"])
  
  name              = "${local.name_prefix}-${each.key}-alerts"
  kms_master_key_id = aws_kms_key.encryption_keys["secrets"].id
  
  tags = merge(
    local.common_tags,
    {
      Name     = "${local.name_prefix}-${each.key}-alerts"
      Severity = each.key
    }
  )
}

# =============================================================================
# LAMBDA FOR SECRETS ROTATION
# =============================================================================

resource "aws_lambda_function" "secrets_rotation" {
  count = var.enable_secrets_rotation ? 1 : 0
  
  filename      = "${path.module}/lambda/secrets_rotation.zip"
  function_name = "${local.name_prefix}-secrets-rotation"
  role          = module.iam.role_arns["lambda_role"]
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 60
  
  environment {
    variables = {
      ENVIRONMENT = var.environment
      REGION      = var.primary_region
    }
  }
  
  tags = local.common_tags
}

# =============================================================================
# NULL RESOURCE FOR DEPENDENCY MANAGEMENT
# =============================================================================

resource "null_resource" "dependency_tracker" {
  triggers = {
    vpc_id        = module.vpc.vpc_id
    rds_endpoint  = try(module.rds[0].endpoint, "")
    timestamp     = timestamp()
  }
  
  provisioner "local-exec" {
    command = "echo 'Infrastructure deployment completed at ${timestamp()}' >> deployment.log"
  }
  
  depends_on = [
    module.vpc,
    module.ec2_instances,
    module.rds,
    module.s3_buckets
  ]
}
