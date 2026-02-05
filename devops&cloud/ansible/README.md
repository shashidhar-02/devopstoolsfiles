# Ansible DevOps Configuration

Complete Ansible configuration demonstrating all production DevOps practices and senior-level topics.

## 📁 Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration with SSH optimizations
├── site.yml                 # Main playbook (entry point)
├── inventory                # Static inventory file
├── aws_ec2.yml             # Dynamic inventory for AWS
├── secrets.yml             # Vault-encrypted secrets
│
├── group_vars/             # Group-level variables
│   ├── all.yml            # Variables for all hosts
│   ├── webservers.yml     # Web server specific vars
│   └── dbservers.yml      # Database server specific vars
│
├── host_vars/              # Host-specific variables
│   ├── web01.example.com.yml
│   └── db01.example.com.yml
│
├── templates/              # Jinja2 templates
│   ├── app-config.yml.j2
│   ├── app-workers.conf.j2
│   └── app.service.j2
│
└── roles/                  # Role-based structure
    ├── common/
    │   ├── tasks/main.yml
    │   └── handlers/main.yml
    ├── nginx/
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   └── templates/
    │       ├── nginx.conf.j2
    │       └── vhost.conf.j2
    └── application/
        ├── tasks/main.yml
        └── handlers/main.yml
```

## 🎯 Must-Know Topics Covered

### ✅ Role-based Structure

- Modular design with reusable roles (common, nginx, application)
- Clean separation of concerns
- Industry-standard role layout

### ✅ Idempotency

- All tasks are idempotent (safe to run multiple times)
- Uses proper Ansible modules (apt, service, file, etc.)
- State management with `state: present/absent`

### ✅ Jinja2 Templating

- Dynamic configuration generation
- Conditional logic (`{% if %}`, `{% else %}`)
- Variable interpolation (`{{ variable }}`)
- Loops and filters
- Environment-specific configurations

### ✅ Dynamic Inventory (Cloud)

- AWS EC2 dynamic inventory (`aws_ec2.yml`)
- Auto-discovery of instances
- Tag-based grouping
- Caching for performance

### ✅ SSH Optimizations

- ControlMaster for connection reuse
- Pipelining enabled
- Connection persistence (60s)
- Parallel execution (20 forks)
- Smart fact gathering

### ✅ Secret Management

- Ansible Vault integration
- Encrypted sensitive data
- Password files for automation
- Secure variable injection

### ✅ Conditional Execution

- Environment-based logic (`when: env == 'production'`)
- OS-specific tasks
- Feature flags
- Dynamic resource allocation

### ✅ Error Recovery

- Retry logic with `retries` and `delay`
- `ignore_errors` for graceful degradation
- `until` loops for health checks
- `register` for result handling

### ✅ Playbook Optimization

- Fact caching
- Smart gathering
- Parallel execution (strategy: free)
- Task tags for selective execution
- Handler notifications

### ✅ Day-2 Operations

- **Patching**: Rolling security updates with `serial: "30%"`
- **Scaling**: Dynamic worker configuration based on load
- Automated reboots when needed
- Health checks and validation

## 🚀 Usage

### Basic Playbook Execution

```bash
# Run entire playbook
ansible-playbook site.yml

# Run specific tags
ansible-playbook site.yml --tags web

# Run on specific hosts
ansible-playbook site.yml --limit webservers

# Check mode (dry run)
ansible-playbook site.yml --check

# With vault password
ansible-playbook site.yml --vault-password-file .vault_pass
```

### Using Dynamic Inventory

```bash
# List all hosts from AWS
ansible-inventory -i aws_ec2.yml --list

# Run playbook with dynamic inventory
ansible-playbook -i aws_ec2.yml site.yml
```

### Secret Management

```bash
# Create vault password file
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass

# Encrypt secrets file
ansible-vault encrypt secrets.yml --vault-password-file .vault_pass

# Edit encrypted file
ansible-vault edit secrets.yml --vault-password-file .vault_pass

# View encrypted file
ansible-vault view secrets.yml --vault-password-file .vault_pass
```

### Day-2 Operations

#### Security Patching (30% at a time)

```bash
ansible-playbook site.yml --tags patching
```

#### Scaling Operations

```bash
# Update worker count in group_vars/webservers.yml
# Then run:
ansible-playbook site.yml --tags scaling
```

## 📊 Best Practices Implemented

1. **Idempotent**: Safe to run repeatedly
2. **Modular**: Reusable roles across projects
3. **Secure**: Vault-encrypted secrets
4. **Optimized**: SSH pipelining, fact caching
5. **Resilient**: Error recovery, retries
6. **Flexible**: Jinja2 templating, conditionals
7. **Production-Ready**: Day-2 ops, rolling updates
8. **Well-Documented**: Clear comments, structure

## 🔐 Security Considerations

- Never commit `.vault_pass` to git (add to `.gitignore`)
- Use Ansible Vault for all secrets
- Implement least-privilege SSH access
- Use jump hosts for production
- Enable SELinux/AppArmor
- Regular security patching automation

## 📈 Scaling & Performance

- **Forks**: 20 parallel hosts
- **Strategy**: Free (non-blocking)
- **Fact caching**: 1 hour
- **SSH persistence**: 60s
- **Pipelining**: Enabled
- **Dynamic inventory caching**: 5 minutes

## 🎓 Senior DevOps Level

This configuration demonstrates senior-level understanding of:

- Infrastructure as Code (IaC)
- Configuration Management
- Automation & Orchestration
- Security & Compliance
- Performance Optimization
- Day-2 Operations
- Production Best Practices

Perfect for **Senior DevOps**, **SRE**, and **Platform Engineering** roles.
