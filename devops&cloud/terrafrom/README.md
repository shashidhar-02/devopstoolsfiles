# Enterprise Terraform Infrastructure as Code

Comprehensive enterprise-level Terraform configuration demonstrating best practices, multi-account/multi-region deployments, reusable modules, remote state management, and policy-as-code.

## 📁 Project Structure

```
terraform/
├── main.tf                    # Main infrastructure configuration
├── variables.tf               # Variable definitions
├── outputs.tf                # Output definitions
├── providers.tf              # Provider configurations (multi-region, multi-account)
├── backend.tf                # S3 + DynamoDB remote state configuration
├── terraform.tfvars.example  # Example variables file
├── .gitignore               # Git ignore patterns
├── Makefile                 # Common Terraform commands
├── README.md                # This file
│
├── modules/                  # Reusable infrastructure modules
│   ├── vpc/                 # VPC module
│   ├── ec2/                 # EC2 instance module
│   ├── rds/                 # RDS database module
│   ├── s3/                  # S3 bucket module
│   ├── iam/                 # IAM roles/policies module
│   ├── alb/                 # Application Load Balancer module
│   └── asg/                 # Auto Scaling Group module
│
├── environments/            # Environment-specific configurations
│   ├── dev/                # Development environment
│   │   └── terraform.tfvars
│   ├── staging/            # Staging environment
│   │   └── terraform.tfvars
│   └── prod/               # Production environment
│       └── terraform.tfvars
│
├── policies/               # Policy-as-Code
│   ├── opa/               # Open Policy Agent policies
│   │   └── terraform_security.rego
│   └── sentinel/          # HashiCorp Sentinel policies
│       └── terraform_policies.sentinel
│
├── scripts/               # Utility scripts
│   ├── import-existing.sh    # Import existing infrastructure
│   ├── state-recovery.sh     # State recovery procedures
│   └── workspace-setup.sh    # Workspace management
│
└── templates/            # Template files
    └── user_data.sh.tpl  # EC2 user data template
```

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured
- Appropriate IAM permissions
- S3 bucket and DynamoDB table for remote state

### Initial Setup

1. **Clone and navigate to the terraform directory:**

   ```bash
   cd terraform
   ```

2. **Create your variables file:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize Terraform:**

   ```bash
   terraform init
   ```

4. **Select or create workspace:**

   ```bash
   # List workspaces
   terraform workspace list
   
   # Create new workspace
   terraform workspace new dev
   
   # Select workspace
   terraform workspace select dev
   ```

5. **Plan and apply:**

   ```bash
   terraform plan -var-file="environments/dev/terraform.tfvars"
   terraform apply -var-file="environments/dev/terraform.tfvars"
   ```

## 📚 Key Concepts Demonstrated

### 1. Module Design (Reusable Infrastructure)

Modular architecture with reusable components:

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  name            = "my-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]
}
```

### 2. Remote State (S3 + DynamoDB)

Configured in `backend.tf`:

- **S3**: Stores state files with encryption and versioning
- **DynamoDB**: Provides state locking to prevent concurrent modifications
- **Recovery**: Versioned state files for rollback capability

### 3. Multi-Account / Multi-Region

Multiple provider configurations for different accounts and regions:

```hcl
provider "aws" {
  alias  = "production"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::PROD_ACCOUNT:role/TerraformRole"
  }
}

provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
}
```

### 4. Workspaces vs Environment Folders

**Two approaches demonstrated:**

#### Workspaces Approach

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
terraform apply -var-file="environments/${TF_WORKSPACE}/terraform.tfvars"
```

#### Environment Folders Approach

```bash
cd environments/dev
terraform init
terraform apply
```

**Recommendation**: Use environment folders for production to avoid accidental cross-environment changes.

### 5. for_each, count, dynamic

**for_each** - Creating multiple similar resources:

```hcl
resource "aws_security_group" "dynamic_sg" {
  for_each = local.enabled_services
  name     = "${local.name_prefix}-${each.key}-sg"
  # ...
}
```

**count** - Conditional resource creation:

```hcl
module "rds" {
  count  = var.environment == "prod" ? 1 : 0
  source = "./modules/rds"
  # ...
}
```

**dynamic** - Dynamic blocks within resources:

```hcl
dynamic "ingress" {
  for_each = var.ingress_rules
  content {
    from_port   = ingress.value.port
    to_port     = ingress.value.port
    protocol    = "tcp"
  }
}
```

### 6. Dependency Graph

Terraform automatically builds a dependency graph. View it:

```bash
terraform graph | dot -Tpng > graph.png
```

Explicit dependencies can be set:

```hcl
depends_on = [module.vpc, module.iam]
```

### 7. Import Existing Infrastructure

Import existing AWS resources into Terraform state:

```bash
# Import VPC
terraform import module.vpc.aws_vpc.this vpc-12345678

# Import EC2 instance
terraform import 'module.ec2_instances["web"].aws_instance.this' i-1234567890abcdef0

# Import RDS
terraform import 'module.rds[0].aws_db_instance.this' my-database

# Import S3 bucket
terraform import 'module.s3_buckets["data"].aws_s3_bucket.this' my-bucket-name
```

See `scripts/import-existing.sh` for automated import workflows.

### 8. State Locking & Recovery

**State Locking:**

- Automatic via DynamoDB table
- Prevents concurrent modifications
- Force unlock if needed: `terraform force-unlock <LOCK_ID>`

**State Recovery:**

```bash
# List state versions
aws s3api list-object-versions \
  --bucket terraform-state-enterprise-prod \
  --prefix infra/terraform.tfstate

# Recover specific version
aws s3api get-object \
  --bucket terraform-state-enterprise-prod \
  --key infra/terraform.tfstate \
  --version-id <VERSION_ID> \
  recovered-state.tfstate

# Restore state
terraform state push recovered-state.tfstate
```

### 9. Secrets Handling

Multiple approaches demonstrated:

**AWS Secrets Manager:**

```hcl
resource "aws_secretsmanager_secret" "db_password" {
  name       = "${local.name_prefix}-db-password"
  kms_key_id = aws_kms_key.secrets.id
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
}
```

**Random Password Generation:**

```hcl
resource "random_password" "db_password" {
  length  = 32
  special = true
}
```

**Best Practices:**

- Never commit secrets to version control
- Use `sensitive = true` for outputs
- Encrypt secrets with KMS
- Enable automatic rotation

### 10. Policy-as-Code (OPA / Sentinel)

**Open Policy Agent (OPA):**

```bash
# Test policies
conftest test main.tf -p policies/opa/

# Example policy
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
conftest test tfplan.json
```

**HashiCorp Sentinel:**

```bash
# For Terraform Cloud/Enterprise
# Policies automatically enforced during runs
```

Policies enforce:

- Encryption requirements
- Tagging standards
- Network security rules
- Cost controls
- Compliance requirements

## 🔧 Common Operations

### Initialize Backend

```bash
terraform init \
  -backend-config="bucket=terraform-state-enterprise-prod" \
  -backend-config="key=infra/terraform.tfstate" \
  -backend-config="region=us-east-1"
```

### Plan with Specific Variables

```bash
terraform plan -var-file="environments/prod/terraform.tfvars" -out=tfplan
```

### Apply Saved Plan

```bash
terraform apply tfplan
```

### Destroy Environment

```bash
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

### View State

```bash
terraform state list
terraform state show 'module.vpc.aws_vpc.this'
```

### Move Resources

```bash
terraform state mv 'module.old.aws_instance.this' 'module.new.aws_instance.this'
```

### Refresh State

```bash
terraform refresh -var-file="environments/prod/terraform.tfvars"
```

### Generate Dependency Graph

```bash
terraform graph | dot -Tpng > infrastructure-graph.png
```

## 🏗️ Deployment Workflow

### Development

```bash
terraform workspace select dev
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars" -auto-approve
```

### Staging

```bash
terraform workspace select staging
terraform plan -var-file="environments/staging/terraform.tfvars"
terraform apply -var-file="environments/staging/terraform.tfvars"
```

### Production

```bash
terraform workspace select prod
terraform plan -var-file="environments/prod/terraform.tfvars" -out=prod.tfplan
# Review plan carefully
terraform apply prod.tfplan
```

## 🔐 Security Best Practices

1. **Remote State**: Always use encrypted S3 backend with state locking
2. **Secrets**: Never commit sensitive data; use AWS Secrets Manager
3. **IAM**: Use least privilege principle; assume roles for operations
4. **Encryption**: Enable encryption at rest and in transit
5. **MFA**: Require MFA for production deployments
6. **Audit**: Enable CloudTrail and Config for compliance
7. **Policy**: Enforce policies with OPA/Sentinel before apply

## 📊 Cost Optimization

- Use `t3` instances for non-production environments
- Disable NAT Gateways in dev (costs ~$32/month per AZ)
- Reduce RDS backup retention for dev/staging
- Use lifecycle policies for S3
- Implement auto-scaling based on demand
- Tag resources for cost allocation

## 🐛 Troubleshooting

### State Lock Issues

```bash
# View lock info
terraform force-unlock <LOCK_ID>
```

### Module Not Found

```bash
terraform get
terraform init -upgrade
```

### Provider Plugin Issues

```bash
rm -rf .terraform
terraform init
```

### State Drift

```bash
terraform plan -refresh-only
terraform apply -refresh-only
```

## 📖 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [OPA Documentation](https://www.openpolicyagent.org/docs/latest/)
- [Sentinel Documentation](https://docs.hashicorp.com/sentinel)

## 📄 License

Enterprise Internal Use Only

## 👥 Support

Contact: <platform-team@company.com>
Slack: #infrastructure
