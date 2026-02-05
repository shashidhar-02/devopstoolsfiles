# Python DevOps Automation Toolkit

Production-grade Python tools for DevOps automation, AWS management, alerting, and CI/CD integration.

## Overview

This module contains 4 comprehensive Python tools demonstrating essential DevOps patterns:

| Tool | Purpose | Key Technologies |
|------|---------|------------------|
| **aws_cleanup.py** | AWS resource cleanup for cost optimization | boto3, argparse, JSON, retry logic |
| **alert_handler.py** | Alert routing with multiple destinations | requests, YAML, dataclasses, REST APIs |
| **ci_helper.py** | CI/CD pipeline validation and K8s deployment | subprocess, kubectl, Docker registry, YAML |
| **backup_tool.py** | Database and file system backup with S3 upload | mysqldump, tar, boto3, compression |

## Installation

### Requirements

- Python 3.8+
- AWS credentials configured (for S3 features)
- MySQL client (for database backups)
- kubectl (for K8s operations)

### Setup

```bash
pip install -r requirements.txt
```

## Tools Documentation

### 1. AWS Cleanup Tool

**Purpose**: Identify and remove unused AWS resources to reduce cloud costs.

**Features**:

- Identify stopped EC2 instances (configurable days threshold)
- Find unattached EBS volumes
- Discover unassociated Elastic IPs
- Dry-run mode for validation
- Detailed JSON reporting
- Retry logic with exponential backoff

**Usage**:

```bash
# Dry-run to see what would be deleted
python aws_cleanup.py --region us-east-1 --log-level INFO

# Execute cleanup with confirmation
python aws_cleanup.py --region us-east-1 --execute

# Generate report
python aws_cleanup.py --region us-east-1 --report cleanup_report.json

# Custom logging
python aws_cleanup.py --region us-west-2 --log-file cleanup.log --log-level DEBUG
```

**Output**:

```json
{
  "timestamp": "2024-02-05T12:00:00",
  "region": "us-east-1",
  "stopped_instances": {
    "count": 5,
    "ids": ["i-123456", "i-789012"],
    "total_cost_per_month": 125.50
  },
  "unattached_volumes": {
    "count": 3,
    "ids": ["vol-123456"],
    "total_size_gb": 500
  },
  "unattached_eips": {
    "count": 2,
    "addresses": ["203.0.113.1"]
  }
}
```

**Code Example - Retry Decorator**:

```python
@retry_on_exception(max_retries=3, backoff_factor=2)
def get_stopped_instances(self, days=7):
    """Get stopped instances older than N days"""
    # AWS API call with automatic retry on transient errors
```

### 2. Alert Handler

**Purpose**: Process monitoring alerts and route them to multiple destinations.

**Features**:

- JSON/YAML serialization for alerts
- Multiple router implementations: Slack, PagerDuty, Email
- YAML-based configuration
- HTTP retry strategy (3 retries with backoff)
- Severity-based color coding
- Metadata tagging

**Configuration File** (`alert_config.yaml`):

```yaml
routers:
  slack:
    enabled: true
    webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  
  pagerduty:
    enabled: true
    integration_key: "YOUR_PAGERDUTY_KEY"
  
  email:
    enabled: true
    smtp_server: "smtp.gmail.com"
    from_address: "alerts@example.com"

default_destinations:
  - slack
  - pagerduty
```

**Usage**:

```bash
# Create alert via Python
python alert_handler.py route-alert \
  --title "High CPU Usage" \
  --message "CPU at 85% on prod-server-01" \
  --severity high \
  --source monitoring \
  --config alert_config.yaml

# Process alerts from file
python alert_handler.py process-file \
  --input alerts.json \
  --config alert_config.yaml
```

**Code Example - Alert Model**:

```python
@dataclass
class Alert:
    title: str
    message: str
    severity: str  # critical, high, medium, low
    source: str
    timestamp: str
    tags: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_json(self) -> str:
        """Serialize to JSON"""
    
    def to_dict(self) -> Dict:
        """Convert to dictionary"""
```

**Alert Routing Example**:

```python
# Slack webhook integration
alert_msg = {
    "attachments": [{
        "color": "danger" if severity == "critical" else "warning",
        "title": alert.title,
        "text": alert.message,
        "fields": [{"title": k, "value": v} for k, v in alert.metadata.items()],
        "ts": int(datetime.now().timestamp())
    }]
}

# PagerDuty events API v2
pagerduty_event = {
    "routing_key": integration_key,
    "event_action": "trigger",
    "dedup_key": alert.source,
    "payload": {
        "summary": alert.title,
        "severity": severity_map[alert.severity],
        "source": alert.source,
        "details": alert.metadata
    }
}
```

### 3. CI Helper Tool

**Purpose**: Validate CI/CD builds, Docker images, and Kubernetes deployments.

**Features**:

- Build artifact validation
- Test suite execution with timeout
- Docker image validation via registry API
- Kubernetes deployment status checks
- Manifest validation and application
- YAML parsing and validation
- HTTP retry strategy for API calls

**Usage**:

```bash
# Full validation pipeline
python ci_helper.py validate \
  --artifacts-dir ./build/artifacts \
  --test-command "pytest tests/ -v" \
  --image busybox:latest \
  --registry-url https://docker.io \
  --k8s-manifests ./k8s/

# Check Docker image existence
python ci_helper.py check-image \
  --image myregistry.azurecr.io/myapp:v1.0.0 \
  --registry-url https://myregistry.azurecr.io

# Apply K8s manifests
python ci_helper.py apply-k8s \
  --manifests ./k8s/production/ \
  --namespace production

# Check deployment status
python ci_helper.py check-deployment \
  --deployment myapp \
  --namespace production \
  --timeout 300
```

**Code Example - Validation Pipeline**:

```python
def validate_deployment(self) -> bool:
    """Complete validation pipeline"""
    checks = [
        self.validate_build_artifacts(),
        self.run_tests(),
        self.validate_image_exists(),
        self.apply_k8s_manifests(),
        self.validate_k8s_deployment()
    ]
    return all(checks)
```

**Kubernetes Integration**:

```python
def validate_k8s_deployment(self) -> bool:
    """Check deployment is ready"""
    cmd = ["kubectl", "get", "deployment", self.deployment, 
           "-o", "json", "-n", self.namespace]
    result = json.loads(subprocess.run(cmd, capture_output=True).stdout)
    
    deployment = result['status']
    return deployment['readyReplicas'] == deployment['replicas']
```

### 4. Backup Tool

**Purpose**: Automated backup and recovery for databases and files.

**Features**:

- MySQL backup using mysqldump
- File system backup using tar
- Gzip compression
- MD5 checksum validation
- Backup metadata tracking (JSON)
- S3 upload capability
- Automatic retention-based cleanup
- Restore functionality

**Usage**:

```bash
# Backup MySQL database
python backup_tool.py mysql-backup \
  --host localhost \
  --user root \
  --password secret \
  --database myapp \
  --backup-dir ./backups \
  --retention-days 7

# Backup files directory
python backup_tool.py files-backup \
  --source /app/data \
  --backup-dir ./backups \
  --exclude "*.log" "*.tmp" \
  --retention-days 30

# Upload to S3
python backup_tool.py s3-upload \
  --backup ./backups/mysql_myapp_20240205_120000.tar.gz \
  --bucket my-backup-bucket \
  --prefix db-backups/production
```

**Backup Metadata** (`mysql_myapp_20240205_120000.json`):

```json
{
  "name": "mysql_myapp",
  "timestamp": "2024-02-05T12:00:00.123456",
  "duration_seconds": 45.2,
  "backup_file": "mysql_myapp_20240205_120000.tar.gz",
  "size_bytes": 5242880,
  "checksum": "d41d8cd98f00b204e9800998ecf8427e"
}
```

**Backup Flow**:

```
1. Start backup (record timestamp)
2. Execute dump/tar command
3. Compress with gzip
4. Calculate MD5 checksum
5. Save metadata JSON
6. Cleanup old backups based on retention
7. Optionally upload to S3
```

## Key Patterns Demonstrated

### 1. Retry Logic

```python
# Decorator pattern for automatic retries
@retry_on_exception(max_retries=3, backoff_factor=2)
def aws_api_call():
    # Transient errors automatically retried
    pass

# HTTPAdapter pattern for REST APIs
session = requests.Session()
retry_strategy = Retry(total=3, status_forcelist=[429, 500, 502, 503, 504])
adapter = HTTPAdapter(max_retries=retry_strategy)
session.mount("http://", adapter)
session.mount("https://", adapter)
```

### 2. Error Handling

```python
# Specific exception handling
try:
    response = session.post(url, json=data, timeout=10)
except requests.exceptions.RequestException as e:
    logger.error(f"API call failed: {str(e)}")
    return False
```

### 3. Configuration Management

```python
# YAML configuration loading
with open("config.yaml", "r") as f:
    config = yaml.safe_load(f)

# JSON reporting
with open("report.json", "w") as f:
    json.dump(results, f, indent=2)
```

### 4. Subprocess Integration

```python
# Safe subprocess execution
result = subprocess.run(
    ["kubectl", "apply", "-f", manifest_file],
    capture_output=True,
    text=True,
    timeout=30
)
```

### 5. Dataclasses for Type Safety

```python
@dataclass
class Alert:
    title: str
    message: str
    severity: str
    
    def to_json(self) -> str:
        return json.dumps(asdict(self))
```

## Best Practices

### AWS Usage

- Always use IAM roles instead of access keys (when possible)
- Implement dry-run mode to validate before execution
- Log all API calls for auditing
- Use exponential backoff for transient errors
- Track costs and cleanup regularly

### Database Backups

- Store backups in multiple locations (local + S3)
- Verify backup integrity with checksums
- Test restore procedures regularly
- Encrypt backups in transit and at rest
- Monitor backup completion times

### Alert Routing

- Filter alerts to reduce noise
- Use appropriate severity levels
- Include context metadata
- Implement deduplication
- Archive alerts for analysis

### CI/CD Integration

- Validate before deployment
- Use timeout values to prevent hanging
- Log detailed error messages
- Implement rollback on validation failure
- Track deployment times and success rates

## Troubleshooting

### AWS Cleanup Issues

```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify IAM permissions
aws iam get-user-policy --user-name <user> --policy-name <policy>

# Enable debug logging
python aws_cleanup.py --region us-east-1 --log-level DEBUG
```

### Alert Handler Issues

```bash
# Validate configuration
python -c "import yaml; yaml.safe_load(open('alert_config.yaml'))"

# Test Slack webhook
curl -X POST -H 'Content-type: application/json' \
  --data '{"attachments":[{"text":"Test"}]}' \
  <WEBHOOK_URL>
```

### CI Helper Issues

```bash
# Verify kubectl access
kubectl cluster-info
kubectl auth can-i get deployments

# Test Docker registry access
curl -u username:password https://registry-url/v2/
```

### Backup Issues

```bash
# Verify MySQL access
mysql -h host -u user -p -e "SELECT VERSION();"

# Test S3 access
aws s3 ls s3://backup-bucket/

# Verify backup integrity
md5sum backup_file.tar.gz
```

## Integration Examples

### GitHub Actions Integration

```yaml
- name: Validate Deployment
  run: |
    python ci_helper.py validate \
      --k8s-manifests ./k8s \
      --image ${{ github.event.pull_request.html_url }}
```

### Kubernetes CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: python:3.10
            command:
            - python
            - /scripts/backup_tool.py
            - mysql-backup
            - --host
            - mysql.default
```

### ECS Task Definition

```json
{
  "name": "cleanup-task",
  "image": "python:3.10",
  "command": ["python", "/scripts/aws_cleanup.py", "--region", "us-east-1", "--execute"]
}
```

## Performance Notes

- **aws_cleanup.py**: O(n) where n = number of resources. ~2-5 minutes for 1000+ resources
- **alert_handler.py**: Handles 100+ alerts/second with async routing
- **ci_helper.py**: Deployment validation typically 30-60 seconds
- **backup_tool.py**: Backup speed limited by I/O and network; 100 MB/s typical throughput

## License

These tools are provided as-is for DevOps automation and learning purposes.
