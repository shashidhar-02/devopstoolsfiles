# DevOps Tools & Configuration Files

A comprehensive collection of DevOps tools, scripts, and configuration files for cloud infrastructure, CI/CD pipelines, Kubernetes, and Terraform.

## Contents

### 📁 devops&cloud/
Complete DevOps configuration files and scripts including:

- **Bash Scripts** - System monitoring, deployment, health checks, and automation scripts
- **CI/CD** - Jenkins, GitHub Actions, GitLab CI, Argo CD configurations
- **Kubernetes** - Manifests for deployments, services, ingress, HPA, network policies, and more
- **Terraform** - Production-ready infrastructure as code with modules for AWS resources (VPC, EC2, RDS, S3, ALB, ASG, IAM)

### 🔧 Key Features

- **Terraform Modules**: Reusable modules for AWS infrastructure
- **K8s Best Practices**: Complete set of Kubernetes resources with security and scaling configurations
- **Automation Scripts**: Shell scripts for monitoring, deployment, and maintenance
- **CI/CD Pipelines**: Ready-to-use pipeline configurations for multiple platforms

## Structure

```
devops&cloud/
├── bash/              # Shell scripts for various DevOps tasks
├── ci,cd/             # CI/CD pipeline configurations
├── k8s/               # Kubernetes manifests
└── terrafrom/         # Terraform infrastructure code
    ├── modules/       # Reusable Terraform modules
    ├── environments/  # Environment-specific configurations
    ├── policies/      # OPA and Sentinel policies
    └── scripts/       # Helper scripts
```

## Usage

Refer to individual directories for specific documentation and usage instructions.
