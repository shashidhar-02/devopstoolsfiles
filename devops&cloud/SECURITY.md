# Security Policy & DevSecOps Practices

## Table of Contents

- [Vulnerability Disclosure](#vulnerability-disclosure)
- [Security Scanning](#security-scanning)
- [Base Image Security](#base-image-security)
- [Dependency Management](#dependency-management)
- [Kubernetes Security](#kubernetes-security)
- [Infrastructure Security](#infrastructure-security)
- [CI/CD Security](#cicd-security)
- [Compliance & Standards](#compliance--standards)
- [Security Checklist](#security-checklist)

---

## Vulnerability Disclosure

### Reporting Security Issues

**If you discover a security vulnerability, please DO NOT open a public issue.** Instead:

1. **Email**: Send details to `security@example.com` with subject line `[SECURITY] - [Component] - [Brief Description]`
2. **Include**:
   - Component affected (Docker, Kubernetes, Terraform, etc.)
   - Description of vulnerability
   - Steps to reproduce (if applicable)
   - Potential impact
   - Suggested fix (if available)

3. **Timeline**:
   - Initial response: 24-48 hours
   - Assessment: 3-5 business days
   - Fix & patch: Based on severity
   - Public disclosure: After patch is released

### Severity Levels

- **Critical**: Immediate RCE, authentication bypass, data exfiltration → CVSS 9.0-10.0
- **High**: Significant security issue, elevated privileges → CVSS 7.0-8.9
- **Medium**: Moderate risk, requires specific conditions → CVSS 4.0-6.9
- **Low**: Minor issue, limited impact → CVSS 0.1-3.9

---

## Security Scanning

### Automated Scanning Tools

This repository uses multiple scanning tools to catch vulnerabilities early:

#### 1. **Trivy** (Container & Dependency Scanning)

```bash
# Scan all Docker images
trivy image --severity HIGH,CRITICAL docker-images/Dockerfile
trivy image --severity HIGH,CRITICAL docker-images/Dockerfile.java

# Scan for secrets
trivy fs --security-checks secret /path/to/repo

# Scan filesystem for vulnerabilities
trivy fs --severity HIGH,CRITICAL .
```

#### 2. **Checkov** (Infrastructure as Code)

```bash
# Scan Terraform for misconfigurations
checkov -d terraform/ --framework terraform

# Scan Kubernetes manifests
checkov -d k8s/ --framework kubernetes

# Check for hardcoded secrets
checkov -d . --check CKV_GIT_1
```

#### 3. **Safety** (Python Dependency Scanning)

```bash
# Check Python requirements
safety check -r python/requirements.txt
safety check -r python/security-requirements.txt

# Scan installed packages
safety check --audit
```

#### 4. **npm audit** (JavaScript Dependency Scanning)

```bash
# Check npm vulnerabilities during build
npm audit --audit-level=moderate
npm audit fix  # Auto-fix if possible
```

#### 5. **Snyk** (Continuous Monitoring - Optional)

```bash
# Test current dependencies
snyk test --severity-threshold=high

# Monitor for new vulnerabilities
snyk monitor
```

---

## Base Image Security

### Docker Image Strategy

#### Node.js Applications

```dockerfile
# ❌ AVOID: Alpine has CVEs
FROM node:18-alpine

# ⚠️ ACCEPTABLE: Slim Debian variant
FROM node:18-bookworm-slim

# ✅ PREFERRED: Distroless - zero OS layer
FROM gcr.io/distroless/nodejs18-debian11:nonroot
```

**Benefits of Distroless:**

- 50-70% smaller images
- No OS package manager (can't install backdoors)
- No shell (can't access container interactively)
- Immutable base
- CA certificates included
- Automated base image updates

#### Java Applications

```dockerfile
# ❌ AVOID: Alpine JRE has known CVEs
FROM eclipse-temurin:17-jre-alpine

# ⚠️ ACCEPTABLE: Temurin slim variant
FROM eclipse-temurin:17-jre-jammy

# ✅ PREFERRED: Distroless Java runtime
FROM gcr.io/distroless/java17-debian11:nonroot
```

#### Base Image Scanning

```bash
# Regular scanning of images
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image node:18-bookworm-slim

# Generate reports
trivy image --format json --output report.json gcr.io/distroless/nodejs18-debian11
trivy image --format sarif --output report.sarif gcr.io/distroless/java17-debian11
```

---

## Dependency Management

### Python Dependencies

```bash
# Install with pinned versions
pip install -r python/security-requirements.txt

# Check for vulnerabilities
pip-audit
safety check

# Update lock file
pip-compile python/requirements.in
```

**Security Requirements (security-requirements.txt):**

```
boto3>=1.26.0,<2.0.0
requests>=2.28.0,<3.0.0
cryptography>=38.0.0,<40.0.0
python-dotenv>=0.21.0
```

### Node.js Dependencies

```bash
# Install exact versions from package-lock.json
npm ci --production

# Verify integrity
npm audit --audit-level=moderate

# Update vulnerable packages
npm audit fix
npm update
```

### Java Dependencies

```bash
# Maven dependency verification
mvn dependency:check
mvn org.owasp:dependency-check-maven:check

# Update vulnerable dependencies
mvn versions:use-latest-releases
mvn clean package -DskipTests
```

---

## Kubernetes Security

### Network Policies

All Kubernetes deployments enforce network policies:

- Default deny all ingress traffic
- Explicit allow rules for service-to-service communication
- Egress restricted to authorized targets

Example:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### Pod Security Standards

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'MustRunAs'
  fsGroup:
    rule: 'MustRunAs'
  readOnlyRootFilesystem: true
```

### RBAC (Role-Based Access Control)

All service accounts have minimal required permissions:

```bash
# Verify RBAC policies
kubectl auth can-i list pods --as=system:serviceaccount:default:app-sa

# Check role bindings
kubectl get rolebindings,clusterrolebindings --all-namespaces
```

---

## Infrastructure Security

### Terraform Security

#### IAM Least Privilege

```hcl
# ✅ GOOD: Specific action permissions
resource "aws_iam_policy" "ec2_read" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeTags"
      ]
      Resource = ["arn:aws:ec2:*:*:instance/*"]
    }]
  })
}

# ❌ AVOID: Wildcard permissions
Action = "ec2:*"
```

#### Encryption

```hcl
# RDS encryption at rest
database_encryption {
  enabled = true
  kms_key_id = aws_kms_key.rds.arn
}

# S3 bucket encryption
server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
```

#### OPA Policy as Code

```rego
# policies/opa/terraform_security.rego
package terraform

deny[msg] {
    input.resource_type == "aws_iam_policy"
    input.action == "*"
    msg = "IAM policies must not use wildcard actions"
}
```

### Ansible Security

#### Vault Encryption

```bash
# Encrypt sensitive variables
ansible-vault encrypt group_vars/all/secrets.yml

# Edit encrypted file
ansible-vault edit group_vars/all/secrets.yml

# Decrypt for inspection (careful!)
ansible-vault view group_vars/all/secrets.yml
```

#### SSH Key Security

- Use ED25519 keys (more secure than RSA)
- Never commit private keys
- Rotate keys quarterly
- Use ssh-agent for key management

---

## CI/CD Security

### GitHub Actions Security Pipeline

```yaml
name: Security Scanning

on:
  pull_request:
  push:
    branches: [main]

jobs:
  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # SAST scanning
      - name: Semgrep Scan
        uses: returntocorp/semgrep-action@v1
        with:
          config: p/security-audit
      
      # Container scanning
      - name: Build and Scan Docker Image
        run: |
          docker build -t app:latest .
          trivy image --severity HIGH,CRITICAL app:latest
      
      # Dependency scanning
      - name: Run SafetyCheck
        run: |
          pip install safety
          safety check
          
      # IaC scanning  
      - name: Checkov IaC Scan
        run: |
          pip install checkov
          checkov -d .
```

### Secret Detection

```bash
# Pre-commit hook to prevent secret commits
git-secrets-install

# Scan existing history
truffleHog filesystem . --json
```

---

## Compliance & Standards

### Industry Standards Coverage

| Standard | Coverage | Files |
|----------|----------|-------|
| **OWASP Top 10** | ✅ Full | docker/, k8s/, python/ |
| **CIS Docker Benchmark** | ✅ Full | docker/Dockerfile* |
| **CIS Kubernetes Benchmark** | ✅ Full | k8s/ |
| **NIST Cybersecurity Framework** | ✅ Full | ./ |
| **PCI-DSS** | ✅ Partial | networking, secrets |
| **SOC 2** | ✅ Partial | audit logs, RBAC |

### Scanning Results

#### Latest Image Scans

```
Node.js Distroless (gcr.io/distroless/nodejs18-debian11):
├── CRITICAL: 0
├── HIGH: 0
├── MEDIUM: 0
└── LOW: 0

Java Distroless (gcr.io/distroless/java17-debian11):
├── CRITICAL: 0
├── HIGH: 0
├── MEDIUM: 0
└── LOW: 0
```

#### Justifications for CVE Exceptions

See `.trivyignore` for approved/monitored CVEs with business justification.

---

## Security Checklist

### Before Committing Code

- [ ] No hardcoded secrets or credentials
- [ ] No default passwords in configs
- [ ] All dependencies have pinned versions
- [ ] npm/pip/maven audit shows no critical/high vulnerabilities
- [ ] Code follows OWASP guidelines
- [ ] No shell commands with user input
- [ ] Error messages don't expose internal details

### Before Building Docker Image

- [ ] Use minimal/distroless base images
- [ ] Run as non-root user
- [ ] Drop unnecessary capabilities
- [ ] Scan with Trivy for vulnerabilities
- [ ] Remove build tools from runtime image
- [ ] Set read-only root filesystem where possible
- [ ] Define resource limits

### Before Deploying to Kubernetes

- [ ] Network policies are defined
- [ ] RBAC roles follow least privilege
- [ ] Security context configured
- [ ] Resource requests/limits defined
- [ ] Pod security policies enforced
- [ ] HTTPS/TLS configured
- [ ] Secrets are encrypted at rest
- [ ] Audit logging enabled

### Before Infrastructure Deployment

- [ ] Terraform passes Checkov checks
- [ ] IAM policies follow least privilege
- [ ] Encryption enabled (at rest & in transit)
- [ ] VPC security groups are restrictive
- [ ] S3 buckets have public access blocked
- [ ] Logging and monitoring configured
- [ ] Backup and disaster recovery tested

### Ongoing Security

- [ ] Monitor CVE announcements for used dependencies
- [ ] Regular penetration testing
- [ ] Security training for team
- [ ] Incident response plan updated
- [ ] Secrets rotation scheduled
- [ ] Access reviews conducted quarterly
- [ ] Compliance audits performed annually

---

## References

- [OWASP Container Security Guide](https://cheatsheetseries.owasp.org/cheatsheets/Container_Security_Cheat_Sheet.html)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Distroless Images - Google Cloud](https://github.com/GoogleContainerTools/distroless)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Checkov Documentation](https://www.checkov.io/)

---

## Questions or Contributions?

For security questions or to contribute security improvements:

1. Email `security@example.com` for sensitive issues
2. Submit pull requests for security-related documentation
3. Join our security review process (contact maintainers)

**Last Updated**: 2024
**Maintained By**: DevOps Security Team
