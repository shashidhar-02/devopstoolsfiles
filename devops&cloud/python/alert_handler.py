#!/usr/bin/env python3
"""
Alert Handler - Process and route monitoring alerts

Demonstrates:
- REST APIs (HTTP requests)
- JSON/YAML parsing
- Error handling & retry logic
- Logging
- CLI tools with Click framework
- Automation frameworks
"""

import json
import yaml
import logging
import sys
from typing import Dict, List, Optional, Any
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from enum import Enum

# =====================================================================
# LOGGING SETUP
# =====================================================================
def setup_logging(log_level: str = "INFO") -> logging.Logger:
    """Configure logging"""
    logger = logging.getLogger("alert_handler")
    logger.setLevel(getattr(logging, log_level.upper()))
    
    handler = logging.StreamHandler()
    handler.setLevel(getattr(logging, log_level.upper()))
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    
    return logger

logger = setup_logging(log_level="INFO")

# =====================================================================
# ALERT DATA MODELS
# =====================================================================
class AlertSeverity(Enum):
    """Alert severity levels"""
    CRITICAL = "critical"
    WARNING = "warning"
    INFO = "info"
    DEBUG = "debug"

@dataclass
class Alert:
    """Alert data model"""
    title: str
    message: str
    severity: str
    source: str
    timestamp: str
    tags: Dict[str, str] = None
    metadata: Dict[str, Any] = None
    
    def to_dict(self) -> Dict:
        """Convert to dictionary"""
        return asdict(self)
    
    def to_json(self) -> str:
        """Convert to JSON string"""
        return json.dumps(self.to_dict(), indent=2, default=str)

# =====================================================================
# ALERT ROUTERS
# =====================================================================
class AlertRouter:
    """Base class for routing alerts"""
    
    def __init__(self, name: str):
        self.name = name
    
    def send(self, alert: Alert) -> bool:
        """Send alert
        
        Args:
            alert: Alert object
            
        Returns:
            True if successful
        """
        raise NotImplementedError

class SlackRouter(AlertRouter):
    """Route alerts to Slack"""
    
    def __init__(self, webhook_url: str, channel: str = None, username: str = "DevOps Bot"):
        super().__init__("slack")
        self.webhook_url = webhook_url
        self.channel = channel
        self.username = username
        self.session = self._create_session()
    
    def _create_session(self) -> requests.Session:
        """Create requests session with retry logic
        
        Returns:
            Requests session with retry strategy
        """
        session = requests.Session()
        
        # Retry strategy: 3 retries with exponential backoff
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "OPTIONS", "POST"]
        )
        
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("https://", adapter)
        session.mount("http://", adapter)
        
        return session
    
    def send(self, alert: Alert) -> bool:
        """Send alert to Slack
        
        Args:
            alert: Alert object
            
        Returns:
            True if successful
        """
        try:
            # Determine color based on severity
            color_map = {
                AlertSeverity.CRITICAL.value: "danger",
                AlertSeverity.WARNING.value: "warning",
                AlertSeverity.INFO.value: "good",
                AlertSeverity.DEBUG.value: "#808080"
            }
            
            color = color_map.get(alert.severity, "good")
            
            # Build Slack message
            payload = {
                "username": self.username,
                "attachments": [
                    {
                        "color": color,
                        "title": alert.title,
                        "text": alert.message,
                        "fields": [
                            {
                                "title": "Severity",
                                "value": alert.severity.upper(),
                                "short": True
                            },
                            {
                                "title": "Source",
                                "value": alert.source,
                                "short": True
                            },
                            {
                                "title": "Timestamp",
                                "value": alert.timestamp,
                                "short": False
                            }
                        ]
                    }
                ]
            }
            
            if self.channel:
                payload["channel"] = self.channel
            
            # Send request
            response = self.session.post(
                self.webhook_url,
                json=payload,
                timeout=10
            )
            
            response.raise_for_status()
            logger.info(f"✓ Alert sent to Slack: {alert.title}")
            return True
        
        except requests.exceptions.RequestException as e:
            logger.error(f"✗ Failed to send Slack alert: {str(e)}")
            return False

class PagerDutyRouter(AlertRouter):
    """Route alerts to PagerDuty"""
    
    def __init__(self, api_key: str, service_key: str):
        super().__init__("pagerduty")
        self.api_key = api_key
        self.service_key = service_key
        self.base_url = "https://events.pagerduty.com/v2/enqueue"
        self.session = self._create_session()
    
    def _create_session(self) -> requests.Session:
        """Create requests session with retry logic"""
        session = requests.Session()
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504]
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("https://", adapter)
        return session
    
    def send(self, alert: Alert) -> bool:
        """Send alert to PagerDuty
        
        Args:
            alert: Alert object
            
        Returns:
            True if successful
        """
        try:
            # Map severity to PagerDuty severity
            severity_map = {
                AlertSeverity.CRITICAL.value: "critical",
                AlertSeverity.WARNING.value: "warning",
                AlertSeverity.INFO.value: "info",
                AlertSeverity.DEBUG.value: "info"
            }
            
            payload = {
                "routing_key": self.service_key,
                "event_action": "trigger",
                "dedup_key": f"{alert.source}:{alert.title}",
                "payload": {
                    "summary": alert.title,
                    "severity": severity_map.get(alert.severity, "error"),
                    "source": alert.source,
                    "timestamp": alert.timestamp,
                    "custom_details": {
                        "message": alert.message,
                        **alert.metadata or {}
                    }
                }
            }
            
            response = self.session.post(
                self.base_url,
                json=payload,
                headers={"Content-Type": "application/json"},
                timeout=10
            )
            
            response.raise_for_status()
            logger.info(f"✓ Alert sent to PagerDuty: {alert.title}")
            return True
        
        except requests.exceptions.RequestException as e:
            logger.error(f"✗ Failed to send PagerDuty alert: {str(e)}")
            return False

class EmailRouter(AlertRouter):
    """Route alerts via email (mock implementation)"""
    
    def __init__(self, recipients: List[str], smtp_server: str = None):
        super().__init__("email")
        self.recipients = recipients
        self.smtp_server = smtp_server
    
    def send(self, alert: Alert) -> bool:
        """Send alert via email
        
        Args:
            alert: Alert object
            
        Returns:
            True if successful
        """
        try:
            # In production, use smtplib
            email_body = f"""
Alert: {alert.title}
Severity: {alert.severity.upper()}
Source: {alert.source}
Timestamp: {alert.timestamp}

Message:
{alert.message}

Metadata:
{json.dumps(alert.metadata or {}, indent=2)}
            """
            
            logger.info(f"✓ Alert sent via email to {self.recipients}")
            logger.debug(f"Email body:\n{email_body}")
            return True
        
        except Exception as e:
            logger.error(f"✗ Failed to send email alert: {str(e)}")
            return False

# =====================================================================
# ALERT HANDLER
# =====================================================================
class AlertHandler:
    """Main alert handler - routes alerts to configured destinations"""
    
    def __init__(self, config_file: Optional[str] = None):
        """Initialize alert handler
        
        Args:
            config_file: Path to YAML configuration file
        """
        self.routers: Dict[str, AlertRouter] = {}
        
        if config_file:
            self.load_config(config_file)
    
    def load_config(self, config_file: str):
        """Load configuration from YAML file
        
        Args:
            config_file: Path to YAML config file
        """
        try:
            config_path = Path(config_file)
            
            if not config_path.exists():
                logger.error(f"Config file not found: {config_file}")
                return
            
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)
            
            logger.info(f"Loaded config from: {config_file}")
            
            # Configure routers
            for router_name, router_config in config.get("routers", {}).items():
                self._setup_router(router_name, router_config)
        
        except Exception as e:
            logger.error(f"Failed to load config: {str(e)}")
    
    def _setup_router(self, name: str, config: Dict):
        """Setup a router from config"""
        router_type = config.get("type")
        
        try:
            if router_type == "slack":
                router = SlackRouter(
                    webhook_url=config["webhook_url"],
                    channel=config.get("channel"),
                    username=config.get("username", "DevOps Bot")
                )
                self.routers[name] = router
            
            elif router_type == "pagerduty":
                router = PagerDutyRouter(
                    api_key=config["api_key"],
                    service_key=config["service_key"]
                )
                self.routers[name] = router
            
            elif router_type == "email":
                router = EmailRouter(
                    recipients=config["recipients"],
                    smtp_server=config.get("smtp_server")
                )
                self.routers[name] = router
            
            logger.info(f"✓ Configured router: {name} ({router_type})")
        
        except KeyError as e:
            logger.error(f"Missing required config for {name}: {str(e)}")
    
    def handle_alert(self, alert: Alert, routers: List[str] = None) -> bool:
        """Handle an alert - route to specified routers
        
        Args:
            alert: Alert object
            routers: List of router names to use (None = all)
            
        Returns:
            True if sent to at least one router successfully
        """
        if not routers:
            routers = list(self.routers.keys())
        
        success = False
        
        for router_name in routers:
            if router_name not in self.routers:
                logger.warning(f"Router not configured: {router_name}")
                continue
            
            router = self.routers[router_name]
            if router.send(alert):
                success = True
        
        return success
    
    def handle_alerts_from_file(self, alerts_file: str) -> int:
        """Handle alerts from JSON file
        
        Args:
            alerts_file: Path to JSON file containing alerts
            
        Returns:
            Number of alerts processed
        """
        try:
            alerts_path = Path(alerts_file)
            
            with open(alerts_path, 'r') as f:
                alerts_data = json.load(f)
            
            if not isinstance(alerts_data, list):
                alerts_data = [alerts_data]
            
            count = 0
            for alert_data in alerts_data:
                alert = Alert(
                    title=alert_data["title"],
                    message=alert_data["message"],
                    severity=alert_data.get("severity", "info"),
                    source=alert_data.get("source", "unknown"),
                    timestamp=alert_data.get("timestamp", datetime.now().isoformat()),
                    tags=alert_data.get("tags"),
                    metadata=alert_data.get("metadata")
                )
                
                if self.handle_alert(alert):
                    count += 1
            
            logger.info(f"Processed {count} alerts from {alerts_file}")
            return count
        
        except Exception as e:
            logger.error(f"Failed to process alerts file: {str(e)}")
            return 0

# =====================================================================
# EXAMPLE & TESTING
# =====================================================================
def example_alert():
    """Create example alert handler and send test alert"""
    
    # Create handler
    handler = AlertHandler()
    
    # Register routers (mock for demo)
    handler.routers["slack"] = SlackRouter(webhook_url="https://hooks.slack.com/services/YOUR/WEBHOOK/URL")
    handler.routers["email"] = EmailRouter(recipients=["ops@example.com"])
    
    # Create and handle alert
    alert = Alert(
        title="High CPU Usage on web01",
        message="CPU usage exceeded 80% threshold",
        severity=AlertSeverity.WARNING.value,
        source="prometheus",
        timestamp=datetime.now().isoformat(),
        tags={"environment": "production", "service": "web"},
        metadata={"cpu_usage": "85%", "threshold": "80%"}
    )
    
    logger.info("=" * 60)
    logger.info("Example Alert:")
    logger.info("=" * 60)
    logger.info(alert.to_json())
    
    # Handle alert
    handler.handle_alert(alert, routers=["email"])

if __name__ == "__main__":
    example_alert()
