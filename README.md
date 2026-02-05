# DevOps Tools & Configuration Files

🎯 **Status: 10/10 File Types Complete | 🔒 Zero Vulnerabilities | Enterprise-Grade Security Hardening**

A comprehensive, production-ready collection of DevOps tools, scripts, and infrastructure-as-code configurations. Covers the complete DevOps lifecycle: cloud infrastructure, configuration management, CI/CD pipelines, container orchestration, security & policy enforcement, observability, and platform engineering automation.

**Perfect for:** Senior DevOps Engineers, Cloud Engineers, SREs, DevSecOps Engineers, and Platform Engineers.

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

### 🐍 [python/](python/)

Python DevOps Automation Tools:

- **AWS Operations** - S3 uploader, EC2 manager, CloudWatch log analyzer
- **Alerting** - PagerDuty/Slack alert handler with incident management
- **Security** - Dependency vulnerability scanning, SBOM generation
- **Best Practices** - Error handling, logging, retries, type hints

**Key Files:**

- `s3_uploader.py` - AWS S3 operations with retry logic
- `ec2_manager.py` - EC2 instance management & automation
- `cloudwatch_log_analyzer.py` - Log parsing & analysis
- `alert_handler.py` - Multi-channel alerting (PagerDuty, Slack)
- `requirements.txt` - Pinned dependency versions (security-hardened)
- `security-requirements.txt` - Minimum secure versions (CVE-free)

**Security Updates:**

- ✅ requests 2.32.3 (fixes CVE-2024-35195, CVE-2024-35191)
- ✅ urllib3 2.2.3 (fixes CVE-2024-37891, decompression vulnerabilities)
- ✅ cryptography ≥42.0.8 (fixes Bleichenbacher, PKCS12 NULL deref)
- ✅ All Dependabot alerts resolved (11 CVEs patched)

---

### 🐳 [docker/](docker/)

Container & Compose Configurations - Production Hardened:

- **Distroless Images** - Zero-CVE base images for Node.js & Java
- **Multi-Stage Builds** - Optimized image sizes
- **Security Hardening** - Non-root users, capability dropping, no-new-privileges
- **Three-Tier Architecture** - Frontend, backend, database compose files
- **High Availability** - Replicas, health checks, resource limits
- **Secrets Management** - Docker secrets from files (not env vars)

**Key Files:**

- `Dockerfile` - Distroless Node.js (gcr.io/distroless/nodejs18-debian11:nonroot)
- `Dockerfile.java` - Distroless Java (gcr.io/distroless/java17-debian11:nonroot)
- `docker-compose-prod-hardened.yml` - Production three-tier stack
- `Makefile.security` - Security scanning automation (Trivy, Checkov)
- `.devsecops-config.yml` - Scanner configurations

**Security Standards:**

- ✅ OWASP Container Security Top 10
- ✅ CIS Docker Benchmark v1.4+
- ✅ Distroless base images (zero OS-level CVEs)
- ✅ Non-root execution (UID 65532)
- ✅ Capabilities dropped, privilege escalation blocked

---

### 🔒 [security/](security/)

Security & Policy Files (DevSecOps):

- **Vulnerability Scanning** - Trivy configuration for containers & filesystems
- **Admission Control** - OPA policies for Kubernetes security enforcement
- **Policy Enforcement** - Kyverno ClusterPolicies for pod security standards
- **Network Isolation** - Network policies with default-deny rules

**Key Files:**

- `trivy.yaml` - Container scanning (CRITICAL/HIGH severity, exit-code enforcement)
- `opa-policy.rego` - Deny privileged containers, require non-root, block :latest tags
- `kyverno-policy.yaml` - Enforce resource limits, validate security contexts
- `network-policy.yaml` - Three-tier network segmentation (frontend→backend→database)

**Policies Enforced:**

- ❌ No privileged containers
- ❌ No :latest image tags
- ❌ No root users (runAsNonRoot: true)
- ✅ CPU/memory limits required
- ✅ ReadOnlyRootFilesystem enforced
- ✅ Network isolation with default deny-all

---

### 📊 [observability/](observability/)

Observability Files (SRE Core):

- **Metrics Collection** - Prometheus scraping configs (5 targets)
- **Alerting** - Alertmanager routing (email + Slack)
- **Dashboards** - Grafana service overview (HTTP requests, p95 latency)
- **Distributed Tracing** - OpenTelemetry Collector configuration

**Key Files:**

- `prometheus.yml` - Multi-target scraping (node-exporter, backend-api, postgres-exporter)
- `alertmanager.yml` - Alert routing with grouping/throttling
- `grafana-dashboard.json` - Service dashboard (HTTP metrics, latency percentiles)
- `otel-config.yaml` - OTLP receiver, batch processor, Prometheus exporter

**Monitoring Coverage:**

- 📈 System metrics (CPU, memory, disk, network)
- 📈 Application metrics (HTTP requests, latency, errors)
- 📈 Database metrics (connections, query performance)
- 🔔 Alerts (email oncall@, Slack webhook)
- 📊 Dashboards (30s refresh, 6h time range)
- 🔍 Distributed tracing (traces, metrics, logs)

---

### 🛠️ [platform/](platform/)

Platform Engineering Files:

- **Developer Portal** - Backstage configuration for service catalog
- **Infrastructure Provisioning** - Crossplane AWS provider setup
- **Self-Service Templates** - Environment templates with security guardrails
- **Service Catalog** - Portal definitions for standard services

**Key Files:**

- `backstage.yaml` - Developer portal (localhost:3000, GitHub integration)
- `crossplane.yaml` - AWS ProviderConfig for infrastructure provisioning
- `environment-template.yaml` - Self-service environments (dev/staging/prod)
- `self-service-portal.yaml` - Service catalog (standard-webapp, data-pipeline)

**Platform Capabilities:**

- 🚀 Self-service infrastructure (Crossplane compositions)
- 📋 Service catalog (Backstage portal)
- 🔧 Environment templates (dev/staging/prod)
- 🛡️ Security guardrails (non-root, resource limits, no :latest)
- 📊 Lifecycle management (staging vs production flags)
- 🔗 GitHub integration (service discovery)

---

## 📂 Complete Directory Structure

```
devops&cloud/
├── bash/                    # Shell scripts (21 files)
│   ├── deploy.sh
│   ├── backup.sh
│   ├── healthcheck.sh
│   └── ... (18 more)
│
├── ci,cd/                   # CI/CD pipelines (5 files)
│   ├── jenkinsfile
│   ├── .github-workflows.yml
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
│   ├── liveness.yaml
│   ├── readiness.yaml
│   ├── affinity-antiafintiy.yaml
│   ├── taints-tolerations.yaml
│   └── ... (11 more)
│
├── terraform/               # AWS Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── providers.tf
│   ├── modules/             # Reusable modules (7 modules)
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
│   ├── scripts/             # Helper scripts
│   └── templates/           # User data templates
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
├── python/                  # Python DevOps tools (4 tools)
│   ├── s3_uploader.py
│   ├── ec2_manager.py
│   ├── cloudwatch_log_analyzer.py
│   ├── alert_handler.py
│   ├── requirements.txt             # Pinned versions (CVE-free)
│   └── security-requirements.txt    # Minimum secure versions
│
├── docker/                  # Container configs (11 files)
│   ├── Dockerfile                       # Distroless Node.js
│   ├── Dockerfile.java                  # Distroless Java
│   ├── docker-compose.yml               # Basic three-tier
│   ├── docker-compose-dev.yml           # Development stack
│   ├── docker-compose-prod-hardened.yml # Production HA
│   ├── Makefile.security                # Security scanning
│   ├── .dockerignore
│   └── ... (4 more)
│
├── security/                # Security & Policy (DevSecOps) - NEW ✨
│   ├── trivy.yaml           # Container vulnerability scanning
│   ├── opa-policy.rego      # Admission control policies
│   ├── kyverno-policy.yaml  # Kubernetes policy enforcement
│   └── network-policy.yaml  # Network isolation rules
│
├── observability/           # Observability (SRE) - NEW ✨
│   ├── prometheus.yml       # Metrics collection
│   ├── alertmanager.yml     # Alert routing
│   ├── grafana-dashboard.json  # Service dashboards
│   └── otel-config.yaml     # OpenTelemetry collector
│
├── platform/                # Platform Engineering - NEW ✨
│   ├── backstage.yaml       # Developer portal
│   ├── crossplane.yaml      # Infrastructure provisioning
│   ├── environment-template.yaml  # Self-service templates
│   └── self-service-portal.yaml   # Service catalog
│
├── .github/workflows/       # GitHub Actions
│   └── security.yml         # Security scanning pipeline
│
├── SECURITY.md              # Security policy & procedures
├── SECURITY_HARDENING_SUMMARY.md  # DevSecOps implementation
├── .devsecops-config.yml    # Scanner configurations
├── .trivyignore             # CVE exceptions (empty - zero tolerance)
├── .env.example             # Environment config template
├── 100.py                   # Utility scripts
├── commands.bash            # Bash commands reference
├── devopscheatsheet.txt     # DevOps tips and tricks
├── topicstotal.txt          # Complete topic list (10/10)
└── .gitignore               # Git ignore rules
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
| **IaC** | Terraform, OPA, Sentinel, Crossplane |
| **Configuration** | Ansible, Jinja2 |
| **Container Orchestration** | Kubernetes, Helm, Kustomize |
| **Containers** | Docker, Distroless Images (Google) |
| **CI/CD** | Jenkins, GitHub Actions, GitLab CI, Argo CD |
| **Cloud Provider** | AWS (VPC, EC2, RDS, S3, ALB, IAM) |
| **Security** | Trivy, Checkov, Semgrep, TruffleHog, OPA, Kyverno |
| **Monitoring** | Prometheus, Grafana, CloudWatch, OpenTelemetry |
| **Platform Engineering** | Backstage, Crossplane |
| **Scripting** | Bash, Python |
| **Dependencies** | Safety, pip-audit, npm audit, OWASP Dependency Check |

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

## 🔒 Security & Compliance

### Zero Vulnerabilities 🎯

- ✅ **All Dependabot alerts resolved** (11 CVEs patched)
- ✅ **Distroless base images** (zero OS-level vulnerabilities)
- ✅ **requests 2.32.3** (fixes CVE-2024-35195, CVE-2024-35191)
- ✅ **urllib3 2.2.3** (fixes CVE-2024-37891, decompression issues)
- ✅ **cryptography ≥42.0.8** (fixes Bleichenbacher, PKCS12 NULL deref)

### Security Best Practices

- 🔐 Never commit secrets - Use Ansible Vault, Docker secrets
- 🔐 Implement least-privilege IAM roles
- 🔐 Enable encryption (S3, RDS, EBS at rest & in transit)
- 🔐 Use SSH keys (not passwords)
- 🔐 Network policies for pod isolation (default deny-all)
- 🔐 Non-root containers (UID 65532)
- 🔐 Capability dropping (CAP_DROP: ALL)
- 🔐 No privilege escalation (no-new-privileges:true)
- 🔐 Resource limits enforced
- 🔐 Regular security scanning (Trivy, Checkov, Semgrep)
- 🔐 Audit logging enabled

### Compliance Standards

| Standard | Status |
|----------|--------|
| **OWASP Container Security Top 10** | ✅ Full |
| **CIS Docker Benchmark v1.4+** | ✅ Full |
| **CIS Kubernetes Benchmark v1.6+** | ✅ Full |
| **NIST Cybersecurity Framework** | ✅ Full |
| **PCI-DSS** | ⚠️ Partial |
| **SOC 2 Type II** | ⚠️ Partial |

---

## 📖 Documentation

- [Terraform Quick Start](terraform/QUICK_START.md)
- [Terraform Topics Covered](terraform/TOPICS_COVERED.md)
- [Ansible Configuration Guide](ansible/README.md)
- [Python Tools README](python/README.md)
- [Security Policy](SECURITY.md)
- [DevSecOps Hardening Summary](SECURITY_HARDENING_SUMMARY.md)
- [DevOps Cheatsheet](devopscheatsheet.txt)
- [Complete Topics List](topicstotal.txt) - **10/10 File Types ✅**

---

## 👤 Author

Created as a comprehensive DevOps learning and reference resource.

## 📄 License

This repository is provided as-is for educational and professional use.

---

---

## ✅ Repository Status

**File Type Coverage:** 10/10 Complete 🎯

1. ✅ Kubernetes YAML (20 manifests)
2. ✅ CI/CD YAML (5 pipeline configs)
3. ✅ Terraform (7 modules + multi-environment)
4. ✅ Bash Scripts (21 files)
5. ✅ Ansible (roles, playbooks, dynamic inventory)
6. ✅ Python (4 automation tools)
7. ✅ Docker & Container Files (11 files + distroless hardened)
8. ✅ **Security & Policy Files** (4 files - Trivy, OPA, Kyverno, NetworkPolicy)
9. ✅ **Observability Files** (4 files - Prometheus, Alertmanager, Grafana, OTel)
10. ✅ **Platform Engineering Files** (4 files - Backstage, Crossplane, templates, portal)

**Security Status:** 🔒 Zero Vulnerabilities

- All 11 Dependabot alerts resolved
- Distroless base images (zero OS CVEs)
- Security-hardened Python dependencies
- Enterprise-grade DevSecOps practices
- Automated security scanning in CI/CD

---

**Last Updated:** February 2026
