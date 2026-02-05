# DevOps Tools & Configuration Files

A comprehensive, production-ready collection of DevOps tools, scripts, and infrastructure-as-code configurations. Covers the complete DevOps lifecycle: cloud infrastructure, configuration management, CI/CD pipelines, container orchestration, and automation.

**Perfect for:** Senior DevOps Engineers, Cloud Engineers, SREs, and Platform Engineers.

---

## 📚 Contents

### 🐚 [bash/](bash/)
Production-grade Shell scripts for DevOps operations:
- **Monitoring** - CPU, memory, disk, network, process checks
- **Deployment** - Rolling deployments, health checks, application management
- **System Operations** - Backup, cleanup, cron jobs, log rotation
- **Infrastructure** - SSH health checks, port management, user auditing
- **Safety** - Error handling, signal trapping, retry logic

**Example Files:**
- `deploy.sh`, `backup.sh`, `health-check.sh`, `memory-monitor.sh`
- `network-check.sh`, `port-check.sh`, `process-check.sh`

---

### 🔄 [ci,cd/](ci,cd/)
CI/CD Pipeline Configurations:
- **Jenkins** - Jenkinsfile with stages, parallel builds, deployment gates
- **GitHub Actions** - `.githubworkflows.yml` for automated testing & deployment
- **GitLab CI** - `.git-lab.ci.yaml` with pipeline stages
- **Argo CD** - GitOps deployments with `argo-application.yaml` & `argo-rollout.yaml`

**Key Features:**
- Multi-environment pipelines (dev/staging/prod)
- Automated testing, building, and deployment
- Rollback strategies and canary deployments
- Policy enforcement and security gates

---

### ☸️ [k8s/](k8s/)
Kubernetes Manifests - Production Best Practices:
- **Core Resources** - Deployment, Service, Ingress, ConfigMap, Secret, Namespace
- **Advanced Scaling** - HPA (Horizontal Pod Autoscaling), StatefulSet, DaemonSet
- **Reliability** - Liveness, Readiness, Startup probes, PDB (Pod Disruption Budget)
- **Networking** - NetworkPolicy, Ingress, Service routing
- **Security** - RBAC (Role, ClusterRole), SecurityContext, PriorityClass
- **Optimization** - Affinity, Anti-affinity, Taints & Tolerations
- **Package Management** - Helm values, Kustomize overlays

**Topics Covered:**
- Resource requests & limits
- Rolling updates & deployment strategies
- Multi-environment configurations
- Security hardening
- High availability patterns

---

### 🏗️ [terraform/](terraform/)
Infrastructure-as-Code for AWS - Production Ready:

**Modules:**
- **VPC** - Virtual Private Cloud with subnets, route tables, NAT gates
- **EC2** - Compute instances with security groups, auto-scaling
- **RDS** - Managed databases with backups, failover, read replicas
- **S3** - Object storage with versioning, encryption, replication
- **ALB** - Application Load Balancer with health checks, routing
- **ASG** - Auto Scaling Groups with scaling policies
- **IAM** - Identity & Access Management, roles, policies

**Features:**
- Multi-account & multi-region support
- Remote state backend (S3 + DynamoDB locking)
- Environment-specific configurations (dev/staging/prod)
- Policy-as-Code (OPA & Sentinel)
- Workspace & module management
- Import existing infrastructure
- State recovery scripts

**Documentation:**
- [QUICK_START.md](terraform/QUICK_START.md)
- [TOPICS_COVERED.md](terraform/TOPICS_COVERED.md)
- [README.md](terraform/README.md)

---

### 🤖 [ansible/](ansible/)
Configuration Management & Day-2 Operations:

**Topics Covered:**
- ✅ **Role-based Structure** - Modular, reusable roles
- ✅ **Idempotency** - Safe to run multiple times
- ✅ **Jinja2 Templating** - Dynamic configurations
- ✅ **Dynamic Inventory** - AWS EC2 auto-discovery
- ✅ **SSH Optimizations** - ControlMaster, pipelining
- ✅ **Secret Management** - Ansible Vault integration
- ✅ **Conditional Execution** - Environment-based logic
- ✅ **Error Recovery** - Retries, graceful degradation
- ✅ **Playbook Optimization** - Parallel execution, fact caching
- ✅ **Day-2 Operations** - Security patching, scaling automation

**Roles:**
- **common** - Base packages, NTP, firewall, monitoring setup
- **nginx** - Web server with SSL, health checks, load balancing
- **application** - App deployment, systemd services, configuration

**Key Files:**
- `site.yml` - Main playbook (entry point)
- `inventory` - Static and dynamic inventory
- `group_vars/` & `host_vars/` - Variable management
- `templates/` - Jinja2 templates for configs
- `ansible.cfg` - Production-grade settings
- `secrets.yml` - Vault-encrypted sensitive data

**Documentation:** [ansible/README.md](ansible/README.md)

---

## 📂 Complete Directory Structure

```
devops&cloud/
├── bash/                    # Shell scripts (21 files)
│   ├── deploy.sh
│   ├── backup.sh
│   ├── health-check.sh
│   └── ... (18 more)
│
├── ci,cd/                   # CI/CD pipelines
│   ├── jenkinsfile
│   ├── .github/workflows/
│   ├── .git-lab.ci.yaml
│   ├── argo-application.yaml
│   └── argo-rollout.yaml
│
├── k8s/                     # Kubernetes manifests (20 files)
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── statefulset.yaml
│   └── ... (15 more)
│
├── terraform/               # AWS Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── ansible.cfg
│   ├── modules/             # Reusable modules
│   │   ├── vpc/
│   │   ├── ec2/
│   │   ├── rds/
│   │   ├── s3/
│   │   ├── alb/
│   │   ├── asg/
│   │   └── iam/
│   ├── environments/        # Environment configs
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   ├── policies/            # Policy-as-Code
│   │   ├── opa/
│   │   └── sentinel/
│   └── scripts/             # Helper scripts
│
├── ansible/                 # Configuration Management
│   ├── site.yml            # Main playbook
│   ├── inventory            # Static inventory
│   ├── aws_ec2.yml         # Dynamic inventory
│   ├── ansible.cfg         # Configuration
│   ├── secrets.yml         # Vault-encrypted secrets
│   ├── group_vars/         # Group variables
│   ├── host_vars/          # Host variables
│   ├── templates/          # Jinja2 templates
│   ├── roles/              # Ansible roles
│   │   ├── common/
│   │   ├── nginx/
│   │   └── application/
│   └── README.md
│
├── 100.py                   # Python utility scripts
├── commands.bash           # Common bash commands reference
├── devopscheatsheet.txt    # DevOps tips and tricks
├── topicstotal.txt         # Complete topic list
└── .gitignore              # Git ignore rules
```

---

## 🚀 Quick Start

### Prerequisites
```bash
# Terraform
terraform --version  # >= 1.0

# Kubernetes
kubectl version

# Ansible
ansible --version

# AWS CLI (for dynamic inventory)
aws --version
```

### Deploy Infrastructure with Terraform
```bash
cd terraform/
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Configure Systems with Ansible
```bash
cd ansible/

# Check inventory
ansible-inventory -i inventory --list

# Run playbook with vault password
ansible-playbook site.yml --vault-password-file .vault_pass

# Deploy to webservers only
ansible-playbook site.yml --limit webservers

# Check mode (dry run)
ansible-playbook site.yml --check
```

### Deploy Applications to Kubernetes
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

### Run Bash Scripts
```bash
cd bash/

# Deploy application
./deploy.sh

# Health check
./health-check.sh

# Backup database
./backup.sh

# Monitor resources
./memory-monitor.sh
```

---

## 📊 Key Technologies

| Area | Technologies |
|------|-----------|
| **IaC** | Terraform, OPA, Sentinel |
| **Configuration** | Ansible, Jinja2 |
| **Container Orchestration** | Kubernetes, Helm, Kustomize |
| **CI/CD** | Jenkins, GitHub Actions, GitLab CI, Argo CD |
| **Cloud Provider** | AWS (VPC, EC2, RDS, S3, ALB, IAM) |
| **Monitoring** | Prometheus, Grafana, CloudWatch |
| **Scripting** | Bash, Python |

---

## 🎓 Learning Path

**Beginner:**
1. Start with `bash/` - Learn shell scripting basics
2. Explore `k8s/` - Understand Kubernetes manifests
3. Read `devopscheatsheet.txt` - DevOps fundamentals

**Intermediate:**
1. Study `terraform/` - Infrastructure-as-Code concepts
2. Understand `ci,cd/` - Pipeline automation
3. Explore `ansible/` - Configuration management

**Advanced:**
1. Multi-environment deployments (Terraform)
2. Policy-as-Code (OPA, Sentinel)
3. Advanced Kubernetes patterns (StatefulSet, DaemonSet, Operators)
4. GitOps with Argo CD
5. Production hardening & security

---

## 🛠️ Use Cases

- ✅ **Greenfield Infrastructure** - Deploy from scratch with Terraform
- ✅ **Configuration Management** - Configure servers with Ansible
- ✅ **Container Deployment** - Deploy apps to Kubernetes
- ✅ **CI/CD Pipelines** - Automate build, test, deploy
- ✅ **Day-2 Operations** - Patching, scaling, backup automation
- ✅ **Multi-environment Setup** - Dev, staging, production
- ✅ **Infrastructure Auditing** - Policy enforcement with OPA
- ✅ **Disaster Recovery** - State recovery scripts, backups

---

## 📝 Best Practices Implemented

- **Idempotent** - Safe to run repeatedly
- **Modular** - Reusable components
- **Secure** - Vault encryption, least privilege
- **Optimized** - SSH pipelining, fact caching, parallel execution
- **Resilient** - Error handling, retries, health checks
- **Flexible** - Conditional logic, dynamic configs
- **Production-Ready** - Multi-environment, high availability
- **Well-Documented** - Clear comments, READMEs, examples

---

## 🔒 Security Considerations

- Never commit secrets - Use Ansible Vault
- Implement least-privilege IAM roles
- Enable encryption (S3, RDS, EBS)
- Use SSH keys (not passwords)
- Network policies for pod isolation
- Regular security patching
- Audit logging enabled

---

## 📖 Documentation

- [Terraform Quick Start](terraform/QUICK_START.md)
- [Terraform Topics](terraform/TOPICS_COVERED.md)
- [Ansible Guide](ansible/README.md)
- [DevOps Cheatsheet](devopscheatsheet.txt)
- [Complete Topics List](topicstotal.txt)

---

## 👤 Author

Created as a comprehensive DevOps learning and reference resource.

## 📄 License

This repository is provided as-is for educational and professional use.

---

**Last Updated:** February 2026
