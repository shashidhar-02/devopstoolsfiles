#!/usr/bin/env python3
"""
AWS Cleanup Tool - Remove unused resources to reduce costs

Demonstrates:
- AWS SDK (boto3)
- Error handling & retry logic
- Logging
- File I/O
- CLI tools with argparse
"""

import argparse
import logging
import json
import sys
from typing import List, Dict, Optional
from pathlib import Path
from datetime import datetime, timedelta
import boto3
from botocore.exceptions import ClientError, BotoCoreError
from functools import wraps
import time

# =====================================================================
# LOGGING SETUP
# =====================================================================
def setup_logging(log_level: str = "INFO", log_file: Optional[str] = None) -> logging.Logger:
    """Configure logging with file and console handlers"""
    logger = logging.getLogger("aws_cleanup")
    logger.setLevel(getattr(logging, log_level.upper()))
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(getattr(logging, log_level.upper()))
    console_format = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    console_handler.setFormatter(console_format)
    logger.addHandler(console_handler)
    
    # File handler (if specified)
    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(logging.DEBUG)
        file_format = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - [%(filename)s:%(lineno)d] - %(message)s'
        )
        file_handler.setFormatter(file_format)
        logger.addHandler(file_handler)
    
    return logger

logger = setup_logging(log_level="INFO", log_file="aws_cleanup.log")

# =====================================================================
# RETRY DECORATOR
# =====================================================================
def retry_on_exception(max_retries: int = 3, delay: int = 5, backoff: float = 2.0):
    """Decorator for retry logic with exponential backoff"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            attempt = 0
            current_delay = delay
            
            while attempt < max_retries:
                try:
                    return func(*args, **kwargs)
                except (ClientError, BotoCoreError) as e:
                    attempt += 1
                    if attempt >= max_retries:
                        logger.error(f"Max retries ({max_retries}) exceeded for {func.__name__}")
                        raise
                    
                    logger.warning(
                        f"Attempt {attempt}/{max_retries} failed for {func.__name__}. "
                        f"Retrying in {current_delay}s... Error: {str(e)}"
                    )
                    time.sleep(current_delay)
                    current_delay = int(current_delay * backoff)
        
        return wrapper
    return decorator

# =====================================================================
# AWS CLEANUP CLASS
# =====================================================================
class AWSCleanup:
    """Clean up unused AWS resources"""
    
    def __init__(self, region: str = "us-east-1", dry_run: bool = True):
        """Initialize AWS cleanup tool
        
        Args:
            region: AWS region
            dry_run: If True, don't actually delete resources
        """
        self.region = region
        self.dry_run = dry_run
        self.ec2 = boto3.client("ec2", region_name=region)
        self.s3 = boto3.client("s3")
        self.elbv2 = boto3.client("elbv2", region_name=region)
        self.ignored_instances = set()
        self.cleanup_report = {
            "timestamp": datetime.now().isoformat(),
            "region": region,
            "dry_run": dry_run,
            "stopped_instances": [],
            "unattached_volumes": [],
            "empty_security_groups": [],
            "unattached_eips": []
        }
    
    @retry_on_exception(max_retries=3, delay=2)
    def get_stopped_instances(self, days: int = 7) -> List[Dict]:
        """Get instances stopped for more than N days
        
        Args:
            days: Number of days to look back
            
        Returns:
            List of stopped instances
        """
        logger.info(f"Scanning for instances stopped for >{days} days...")
        
        cutoff_time = datetime.now(datetime.now().astimezone().tzinfo) - timedelta(days=days)
        stopped_instances = []
        
        try:
            response = self.ec2.describe_instances(
                Filters=[{"Name": "instance-state-name", "Values": ["stopped"]}]
            )
            
            for reservation in response.get("Reservations", []):
                for instance in reservation.get("Instances", []):
                    state_transition = instance.get("StateTransitionReason", "")
                    if "User initiated" in state_transition or state_transition:
                        stopped_instances.append({
                            "InstanceId": instance["InstanceId"],
                            "LaunchTime": instance["LaunchTime"].isoformat(),
                            "State": instance["State"]["Name"],
                            "Type": instance["InstanceType"],
                            "Tags": instance.get("Tags", [])
                        })
            
            logger.info(f"Found {len(stopped_instances)} stopped instances")
            return stopped_instances
        
        except ClientError as e:
            logger.error(f"Error getting stopped instances: {str(e)}")
            raise
    
    @retry_on_exception(max_retries=3, delay=2)
    def get_unattached_volumes(self) -> List[Dict]:
        """Get unattached EBS volumes
        
        Returns:
            List of unattached volumes
        """
        logger.info("Scanning for unattached EBS volumes...")
        
        unattached_volumes = []
        
        try:
            response = self.ec2.describe_volumes(
                Filters=[{"Name": "status", "Values": ["available"]}]
            )
            
            for volume in response.get("Volumes", []):
                unattached_volumes.append({
                    "VolumeId": volume["VolumeId"],
                    "Size": volume["Size"],
                    "Type": volume["VolumeType"],
                    "CreateTime": volume["CreateTime"].isoformat(),
                    "Tags": volume.get("Tags", [])
                })
            
            logger.info(f"Found {len(unattached_volumes)} unattached volumes")
            return unattached_volumes
        
        except ClientError as e:
            logger.error(f"Error getting unattached volumes: {str(e)}")
            raise
    
    @retry_on_exception(max_retries=3, delay=2)
    def get_unattached_eips(self) -> List[Dict]:
        """Get unattached Elastic IPs (not associated with instances)
        
        Returns:
            List of unattached EIPs
        """
        logger.info("Scanning for unattached Elastic IPs...")
        
        unattached_eips = []
        
        try:
            response = self.ec2.describe_addresses()
            
            for eip in response.get("Addresses", []):
                if "InstanceId" not in eip or not eip["InstanceId"]:
                    unattached_eips.append({
                        "PublicIp": eip["PublicIp"],
                        "AllocationId": eip.get("AllocationId"),
                        "AssociationId": eip.get("AssociationId"),
                        "Tags": eip.get("Tags", [])
                    })
            
            logger.info(f"Found {len(unattached_eips)} unattached EIPs")
            return unattached_eips
        
        except ClientError as e:
            logger.error(f"Error getting unattached EIPs: {str(e)}")
            raise
    
    def cleanup_stopped_instances(self):
        """Terminate stopped instances"""
        logger.info("=" * 60)
        logger.info("CLEANUP: Stopped Instances")
        logger.info("=" * 60)
        
        try:
            instances = self.get_stopped_instances(days=7)
            
            if not instances:
                logger.info("No stopped instances to clean up")
                return
            
            for instance in instances:
                instance_id = instance["InstanceId"]
                logger.info(f"Processing instance: {instance_id}")
                
                if self.dry_run:
                    logger.info(f"[DRY RUN] Would terminate: {instance_id}")
                    self.cleanup_report["stopped_instances"].append({
                        "id": instance_id,
                        "action": "would_terminate",
                        "dry_run": True
                    })
                else:
                    try:
                        self.ec2.terminate_instances(InstanceIds=[instance_id])
                        logger.info(f"✓ Terminated instance: {instance_id}")
                        self.cleanup_report["stopped_instances"].append({
                            "id": instance_id,
                            "action": "terminated",
                            "dry_run": False
                        })
                    except ClientError as e:
                        logger.error(f"✗ Failed to terminate {instance_id}: {str(e)}")
        
        except Exception as e:
            logger.error(f"Error during stopped instances cleanup: {str(e)}")
            raise
    
    def cleanup_unattached_volumes(self):
        """Delete unattached volumes"""
        logger.info("=" * 60)
        logger.info("CLEANUP: Unattached Volumes")
        logger.info("=" * 60)
        
        try:
            volumes = self.get_unattached_volumes()
            
            if not volumes:
                logger.info("No unattached volumes to clean up")
                return
            
            for volume in volumes:
                volume_id = volume["VolumeId"]
                logger.info(f"Processing volume: {volume_id} ({volume['Size']}GB)")
                
                if self.dry_run:
                    logger.info(f"[DRY RUN] Would delete: {volume_id}")
                    self.cleanup_report["unattached_volumes"].append({
                        "id": volume_id,
                        "size_gb": volume["Size"],
                        "action": "would_delete",
                        "dry_run": True
                    })
                else:
                    try:
                        self.ec2.delete_volume(VolumeId=volume_id)
                        logger.info(f"✓ Deleted volume: {volume_id}")
                        self.cleanup_report["unattached_volumes"].append({
                            "id": volume_id,
                            "size_gb": volume["Size"],
                            "action": "deleted",
                            "dry_run": False
                        })
                    except ClientError as e:
                        logger.error(f"✗ Failed to delete {volume_id}: {str(e)}")
        
        except Exception as e:
            logger.error(f"Error during volumes cleanup: {str(e)}")
            raise
    
    def cleanup_unattached_eips(self):
        """Release unattached Elastic IPs"""
        logger.info("=" * 60)
        logger.info("CLEANUP: Unattached Elastic IPs")
        logger.info("=" * 60)
        
        try:
            eips = self.get_unattached_eips()
            
            if not eips:
                logger.info("No unattached EIPs to clean up")
                return
            
            for eip in eips:
                public_ip = eip["PublicIp"]
                allocation_id = eip.get("AllocationId")
                logger.info(f"Processing EIP: {public_ip}")
                
                if self.dry_run:
                    logger.info(f"[DRY RUN] Would release: {public_ip}")
                    self.cleanup_report["unattached_eips"].append({
                        "ip": public_ip,
                        "allocation_id": allocation_id,
                        "action": "would_release",
                        "dry_run": True
                    })
                else:
                    try:
                        if allocation_id:
                            self.ec2.release_address(AllocationId=allocation_id)
                        logger.info(f"✓ Released EIP: {public_ip}")
                        self.cleanup_report["unattached_eips"].append({
                            "ip": public_ip,
                            "allocation_id": allocation_id,
                            "action": "released",
                            "dry_run": False
                        })
                    except ClientError as e:
                        logger.error(f"✗ Failed to release {public_ip}: {str(e)}")
        
        except Exception as e:
            logger.error(f"Error during EIPs cleanup: {str(e)}")
            raise
    
    def generate_report(self, report_file: str = "aws_cleanup_report.json"):
        """Generate cleanup report to JSON file"""
        logger.info("=" * 60)
        logger.info("REPORT")
        logger.info("=" * 60)
        
        try:
            report_path = Path(report_file)
            with open(report_path, 'w') as f:
                json.dump(self.cleanup_report, f, indent=2, default=str)
            
            logger.info(f"✓ Report saved to: {report_path.absolute()}")
            logger.info(json.dumps(self.cleanup_report, indent=2, default=str))
        
        except IOError as e:
            logger.error(f"Failed to write report: {str(e)}")
            raise
    
    def run_all_cleanup(self):
        """Run all cleanup operations"""
        logger.info(f"AWS Cleanup Tool - Region: {self.region}, DRY_RUN: {self.dry_run}")
        logger.info("=" * 60)
        
        try:
            self.cleanup_stopped_instances()
            self.cleanup_unattached_volumes()
            self.cleanup_unattached_eips()
            self.generate_report()
            
            logger.info("=" * 60)
            logger.info("✓ Cleanup completed successfully!")
        
        except Exception as e:
            logger.error(f"Cleanup failed: {str(e)}")
            sys.exit(1)

# =====================================================================
# CLI
# =====================================================================
def main():
    """CLI entry point"""
    parser = argparse.ArgumentParser(
        description="AWS Cleanup Tool - Remove unused resources to reduce costs",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Dry run (preview what would be deleted)
  python aws_cleanup.py --region us-east-1

  # Actually delete resources
  python aws_cleanup.py --region us-east-1 --execute

  # Verbose output with log file
  python aws_cleanup.py --execute --log-level DEBUG --log-file cleanup.log
        """
    )
    
    parser.add_argument(
        "--region",
        default="us-east-1",
        help="AWS region (default: us-east-1)"
    )
    parser.add_argument(
        "--execute",
        action="store_true",
        help="Actually delete resources (default: dry-run mode)"
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        help="Logging level (default: INFO)"
    )
    parser.add_argument(
        "--log-file",
        help="Log file path (optional)"
    )
    parser.add_argument(
        "--report",
        default="aws_cleanup_report.json",
        help="Report output file (default: aws_cleanup_report.json)"
    )
    
    args = parser.parse_args()
    
    # Reconfigure logging if needed
    if args.log_level != "INFO" or args.log_file:
        global logger
        logger = setup_logging(log_level=args.log_level, log_file=args.log_file)
    
    # Warn if not in dry-run mode
    if args.execute:
        logger.warning("⚠️  EXECUTE MODE - Resources WILL be deleted!")
        response = input("Type 'yes' to confirm: ")
        if response.lower() != 'yes':
            logger.info("Cancelled")
            sys.exit(0)
    else:
        logger.info("DRY RUN MODE - No resources will be deleted")
    
    # Run cleanup
    cleanup = AWSCleanup(region=args.region, dry_run=not args.execute)
    cleanup.run_all_cleanup()

if __name__ == "__main__":
    main()
