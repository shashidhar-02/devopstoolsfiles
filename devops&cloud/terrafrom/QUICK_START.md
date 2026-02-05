# 🚀 QUICK START GUIDE

## Prerequisites Checklist

- [ ] Terraform >= 1.5.0 installed
- [ ] AWS CLI installed and configured
- [ ] IAM permissions for Terraform operations
- [ ] S3 bucket created for state storage
- [ ] DynamoDB table created for state locking

## 🏃 5-Minute Setup

### Step 1: Backend Setup (One-time)

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket terraform-state-enterprise-prod \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-state-enterprise-prod \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket terraform-state-enterprise-prod \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 2: Configure Your Environment

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
# IMPORTANT: Update account IDs, regions, and other settings
nano terraform.tfvars
```

**Key variables to update:**

- `production_account_id`
- `staging_account_id`
- `dev_account_id`
- `owner`
- `cost_center`

### Step 3: Initialize Terraform

```bash
# Initialize backend and providers
terraform init

# Validate configuration
terraform validate

# Format files
terraform fmt -recursive
```

### Step 4: Deploy to Development

```bash
# Create/select dev workspace
terraform workspace new dev

# Plan deployment
terraform plan -var-file=environments/dev/terraform.tfvars

# Apply (if plan looks good)
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Step 5: Verify Deployment

```bash
# Check outputs
terraform output

# List resources
terraform state list

# View specific resource
terraform state show 'module.vpc.aws_vpc.this'
```

## 🎯 Common Use Cases

### Deploy to Different Environment

```bash
# Staging
terraform workspace select staging
terraform plan -var-file=environments/staging/terraform.tfvars
terraform apply -var-file=environments/staging/terraform.tfvars

# Production
terraform workspace select prod
terraform plan -var-file=environments/prod/terraform.tfvars -out=prod.tfplan
terraform apply prod.tfplan
```

### Import Existing Resources

```bash
# Run import wizard
./scripts/import-existing.sh dev

# Or import manually
terraform import \
  -var-file=environments/dev/terraform.tfvars \
  'module.vpc.aws_vpc.this' \
  vpc-12345678
```

### Make Changes to Infrastructure

```bash
# 1. Edit configuration files
nano main.tf

# 2. Plan changes
terraform plan -var-file=environments/dev/terraform.tfvars

# 3. Review plan carefully

# 4. Apply changes
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Recover from State Issues

```bash
# List state versions
./scripts/state-recovery.sh
# Choose option 1

# Recover specific version
./scripts/state-recovery.sh
# Choose option 2, enter Version ID

# Force unlock if stuck
terraform force-unlock <LOCK_ID>
```

## 🛠️ Using the Makefile

The Makefile simplifies common operations:

```bash
# See all commands
make help

# Deploy to dev
make dev

# Deploy to staging
make staging

# Deploy to production (with safeguards)
make prod

# Run all checks
make check

# Plan only
make plan ENV=dev

# Generate dependency graph
make graph

# Run security checks
make security

# Test OPA policies
make policy-opa

# Show outputs
make output ENV=prod
```

## 📋 Pre-Deployment Checklist

### Development Environment

- [ ] Review `environments/dev/terraform.tfvars`
- [ ] Verify AWS credentials for dev account
- [ ] Check cost estimates
- [ ] Plan and review output
- [ ] Apply changes
- [ ] Verify resources in AWS Console
- [ ] Test application connectivity

### Staging Environment

- [ ] All dev testing passed
- [ ] Review `environments/staging/terraform.tfvars`
- [ ] Verify AWS credentials for staging account
- [ ] Run policy checks (`make policy-opa`)
- [ ] Plan and save to file
- [ ] Peer review plan
- [ ] Apply with approval
- [ ] Run integration tests

### Production Environment

- [ ] All staging testing passed
- [ ] Review `environments/prod/terraform.tfvars`
- [ ] Verify AWS credentials for prod account
- [ ] Run security scan (`make security`)
- [ ] Run policy checks (`make policy-opa`)
- [ ] Estimate costs (`make costs`)
- [ ] Plan and save to file
- [ ] Security team review
- [ ] Change advisory board approval
- [ ] Backup current state
- [ ] Apply during maintenance window
- [ ] Monitor CloudWatch metrics
- [ ] Verify all services healthy

## 🔧 Troubleshooting

### "Error: Backend initialization required"

```bash
terraform init
```

### "Error: workspace 'dev' doesn't exist"

```bash
terraform workspace new dev
```

### "Error: State lock"

```bash
# Wait for lock to release, or force unlock
terraform force-unlock <LOCK_ID>
```

### "Error: Module not found"

```bash
terraform get
terraform init -upgrade
```

### "Error: Provider plugin not installed"

```bash
rm -rf .terraform
terraform init
```

### State drift detected

```bash
# See what changed
terraform plan -refresh-only

# Update state to match reality
terraform apply -refresh-only
```

## 📚 Next Steps

1. **Customize Modules**: Adapt modules to your specific needs
2. **Add More Modules**: Create modules for other services (ECS, EKS, etc.)
3. **CI/CD Integration**: Set up automated pipelines
4. **Monitoring**: Configure CloudWatch dashboards
5. **Cost Optimization**: Review and optimize resource sizes
6. **Documentation**: Document your specific configurations
7. **Training**: Train team on this setup

## 🎓 Learning Resources

- **Main README**: Comprehensive documentation
- **TOPICS_COVERED.md**: All topics with examples
- **Module READMEs**: Specific module documentation
- **Scripts**: Study the automation scripts
- **Policies**: Review security policies

## ⚡ Pro Tips

1. **Always plan before apply**: `terraform plan` is your friend
2. **Use workspaces for dev**: Quick environment switching
3. **Use folders for prod**: Complete isolation
4. **Tag everything**: Cost allocation and organization
5. **Version your modules**: Use Git tags for stability
6. **Document changes**: Commit messages matter
7. **Review state regularly**: Catch drift early
8. **Test policies locally**: Before CI/CD enforcement
9. **Backup before major changes**: State recovery is crucial
10. **Monitor costs**: Use AWS Cost Explorer with tags

## 🆘 Getting Help

- Check [README.md](README.md) for detailed documentation
- Review [TOPICS_COVERED.md](TOPICS_COVERED.md) for examples
- Run `make help` for available commands
- Check Terraform documentation: <https://terraform.io/docs>
- AWS Provider docs: <https://registry.terraform.io/providers/hashicorp/aws/latest/docs>

## 🎉 Success Criteria

You'll know it's working when:

- ✅ `terraform init` completes without errors
- ✅ `terraform plan` shows expected resources
- ✅ `terraform apply` creates infrastructure successfully
- ✅ Resources appear in AWS Console
- ✅ Outputs show correct values
- ✅ Application can connect to resources
- ✅ Monitoring shows healthy metrics

---

**Remember**: Start small, test thoroughly, deploy incrementally!
