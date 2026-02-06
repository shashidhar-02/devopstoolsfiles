#!/bin/bash
# User data template for EC2 instances

set -euxo pipefail

# Variables from Terraform
ENVIRONMENT="${environment}"
SERVICE_NAME="${service_name}"
REGION="${region}"

# Update system
yum update -y

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Install SSM agent (if not present)
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<EOF
{
  "metrics": {
    "namespace": "Enterprise/${SERVICE_NAME}",
    "metrics_collected": {
      "cpu": {
        "measurement": [{"name": "cpu_usage_idle", "rename": "CPU_IDLE"}],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [{"name": "used_percent", "rename": "DISK_USED"}],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": [{"name": "mem_used_percent", "rename": "MEM_USED"}],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/${ENVIRONMENT}/${SERVICE_NAME}",
            "log_stream_name": "{instance_id}/messages"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

# Application specific setup
case "$SERVICE_NAME" in
  web)
    yum install -y nginx
    systemctl enable nginx
    systemctl start nginx
    ;;
  api)
    yum install -y python3 python3-pip
    pip3 install flask gunicorn
    ;;
  worker)
    yum install -y python3 python3-pip
    pip3 install celery redis
    ;;
esac

# Signal completion
echo "User data execution completed for $SERVICE_NAME in $ENVIRONMENT" > /var/log/user-data-complete.log
