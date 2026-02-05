#!/usr/bin/env python3
"""
Backup Tool - Automated backup and recovery for databases and files

Demonstrates:
- File I/O
- JSON/YAML parsing
- AWS SDK (boto3)
- Error handling & retry logic
- Logging
- CLI tools with argparse
- Databases and compression
"""

import argparse
import json
import yaml
import logging
import sys
import subprocess
import gzip
import hashlib
from typing import Dict, List, Optional, Tuple
from pathlib import Path
from datetime import datetime, timedelta
import boto3
from botocore.exceptions import ClientError
import tempfile
import shutil

# =====================================================================
# LOGGING SETUP
# =====================================================================
def setup_logging(log_file: Optional[str] = None) -> logging.Logger:
    """Configure logging"""
    logger = logging.getLogger("backup_tool")
    logger.setLevel(logging.INFO)
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    formatter = logging.Formatter(
        '%(asctime)s - %(levelname)s - %(message)s'
    )
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # File handler
    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(logging.DEBUG)
        file_formatter = logging.Formatter(
            '%(asctime)s - %(levelname)s - [%(funcName)s] - %(message)s'
        )
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
    
    return logger

logger = setup_logging(log_file="backup_tool.log")

# =====================================================================
# BACKUP CLASSES
# =====================================================================
class BackupBase:
    """Base class for backup operations"""
    
    def __init__(self, name: str, backup_dir: str, retention_days: int = 7):
        """Initialize backup
        
        Args:
            name: Backup name/identifier
            backup_dir: Directory to store backups
            retention_days: Keep backups for N days
        """
        self.name = name
        self.backup_dir = Path(backup_dir)
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        self.retention_days = retention_days
        self.backup_path = None
        self.start_time = None
        self.end_time = None
        self.metadata = {}
    
    def cleanup_old_backups(self):
        """Remove backups older than retention period"""
        logger.info(f"Cleaning up backups older than {self.retention_days} days...")
        
        cutoff_time = datetime.now() - timedelta(days=self.retention_days)
        deleted = 0
        
        for backup_file in self.backup_dir.glob(f"{self.name}_*.tar.gz"):
            file_time = datetime.fromtimestamp(backup_file.stat().st_mtime)
            
            if file_time < cutoff_time:
                try:
                    backup_file.unlink()
                    logger.info(f"✓ Deleted old backup: {backup_file.name}")
                    deleted += 1
                except Exception as e:
                    logger.error(f"✗ Failed to delete {backup_file.name}: {str(e)}")
        
        logger.info(f"Cleanup complete. Deleted {deleted} backups.")
    
    def calculate_checksum(self, file_path: Path) -> str:
        """Calculate file checksum
        
        Args:
            file_path: Path to file
            
        Returns:
            MD5 checksum
        """
        hash_md5 = hashlib.md5()
        
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        
        return hash_md5.hexdigest()
    
    def save_metadata(self):
        """Save backup metadata to JSON file"""
        metadata = {
            "name": self.name,
            "timestamp": self.start_time.isoformat() if self.start_time else None,
            "duration_seconds": (self.end_time - self.start_time).total_seconds() if self.start_time and self.end_time else None,
            "backup_file": self.backup_path.name if self.backup_path else None,
            "size_bytes": self.backup_path.stat().st_size if self.backup_path and self.backup_path.exists() else None,
            "checksum": self.metadata.get("checksum"),
            **self.metadata
        }
        
        metadata_file = self.backup_dir / f"{self.name}_{self.start_time.strftime('%Y%m%d_%H%M%S')}.json"
        
        try:
            with open(metadata_file, 'w') as f:
                json.dump(metadata, f, indent=2)
            logger.info(f"✓ Metadata saved: {metadata_file.name}")
        except Exception as e:
            logger.error(f"✗ Failed to save metadata: {str(e)}")

class MySQLBackup(BackupBase):
    """MySQL database backup using mysqldump"""
    
    def __init__(self, host: str, user: str, password: str, database: str, backup_dir: str):
        """Initialize MySQL backup
        
        Args:
            host: MySQL host
            user: MySQL user
            password: MySQL password
            database: Database name
            backup_dir: Backup directory
        """
        super().__init__(f"mysql_{database}", backup_dir)
        self.host = host
        self.user = user
        self.password = password
        self.database = database
    
    def backup(self) -> bool:
        """Create MySQL backup using mysqldump
        
        Returns:
            True if successful
        """
        logger.info(f"Starting MySQL backup: {self.database}@{self.host}")
        self.start_time = datetime.now()
        
        try:
            # Create dump file
            dump_file = self.backup_dir / f"{self.name}_{self.start_time.strftime('%Y%m%d_%H%M%S')}.sql"
            
            # Run mysqldump
            cmd = f"mysqldump -h {self.host} -u {self.user} -p{self.password} {self.database} > {dump_file}"
            
            logger.info(f"Executing: mysqldump...")
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=300)
            
            if result.returncode != 0:
                logger.error(f"✗ mysqldump failed: {result.stderr}")
                return False
            
            # Compress
            logger.info("Compressing backup...")
            self.backup_path = self._compress_file(dump_file)
            
            # Calculate checksum
            checksum = self.calculate_checksum(self.backup_path)
            self.metadata["checksum"] = checksum
            logger.info(f"Checksum: {checksum}")
            
            self.end_time = datetime.now()
            duration = (self.end_time - self.start_time).total_seconds()
            size_mb = self.backup_path.stat().st_size / (1024 * 1024)
            
            logger.info(f"✓ Backup complete: {self.backup_path.name}")
            logger.info(f"  Size: {size_mb:.2f} MB")
            logger.info(f"  Duration: {duration:.2f}s")
            
            self.save_metadata()
            return True
        
        except Exception as e:
            logger.error(f"✗ Backup failed: {str(e)}")
            return False
    
    def _compress_file(self, file_path: Path) -> Path:
        """Compress file with gzip
        
        Args:
            file_path: Path to file
            
        Returns:
            Path to compressed file
        """
        compressed_path = Path(str(file_path) + ".gz")
        
        with open(file_path, 'rb') as f_in:
            with gzip.open(compressed_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        
        # Remove original
        file_path.unlink()
        
        return compressed_path
    
    def restore(self, backup_file: str) -> bool:
        """Restore from backup
        
        Args:
            backup_file: Path to backup file
            
        Returns:
            True if successful
        """
        logger.info(f"Restoring from backup: {backup_file}")
        
        try:
            backup_path = Path(backup_file)
            
            if not backup_path.exists():
                logger.error(f"Backup file not found: {backup_file}")
                return False
            
            # Decompress if needed
            if backup_path.suffix == '.gz':
                logger.info("Decompressing backup...")
                with gzip.open(backup_path, 'rb') as f_in:
                    sql_file = backup_path.parent / backup_path.stem
                    with open(sql_file, 'wb') as f_out:
                        shutil.copyfileobj(f_in, f_out)
            else:
                sql_file = backup_path
            
            # Restore
            logger.info("Executing restore...")
            cmd = f"mysql -h {self.host} -u {self.user} -p{self.password} {self.database} < {sql_file}"
            
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=600)
            
            if result.returncode != 0:
                logger.error(f"✗ Restore failed: {result.stderr}")
                return False
            
            logger.info("✓ Restore complete")
            return True
        
        except Exception as e:
            logger.error(f"✗ Restore failed: {str(e)}")
            return False

class FilesBackup(BackupBase):
    """File system backup using tar"""
    
    def __init__(self, source_dir: str, backup_dir: str, exclude_patterns: List[str] = None):
        """Initialize files backup
        
        Args:
            source_dir: Directory to backup
            backup_dir: Backup directory
            exclude_patterns: List of patterns to exclude
        """
        super().__init__(f"files_{Path(source_dir).name}", backup_dir)
        self.source_dir = Path(source_dir)
        self.exclude_patterns = exclude_patterns or []
    
    def backup(self) -> bool:
        """Create file backup using tar
        
        Returns:
            True if successful
        """
        logger.info(f"Starting files backup: {self.source_dir}")
        self.start_time = datetime.now()
        
        try:
            if not self.source_dir.exists():
                logger.error(f"Source directory not found: {self.source_dir}")
                return False
            
            # Build tar command
            backup_filename = f"{self.name}_{self.start_time.strftime('%Y%m%d_%H%M%S')}.tar.gz"
            self.backup_path = self.backup_dir / backup_filename
            
            cmd = f"tar -czf {self.backup_path} -C {self.source_dir.parent} {self.source_dir.name}"
            
            # Add exclude patterns
            for pattern in self.exclude_patterns:
                cmd += f" --exclude='{pattern}'"
            
            logger.info("Creating tar archive...")
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=600)
            
            if result.returncode != 0:
                logger.error(f"✗ Tar failed: {result.stderr}")
                return False
            
            # Calculate checksum
            checksum = self.calculate_checksum(self.backup_path)
            self.metadata["checksum"] = checksum
            logger.info(f"Checksum: {checksum}")
            
            self.end_time = datetime.now()
            duration = (self.end_time - self.start_time).total_seconds()
            size_mb = self.backup_path.stat().st_size / (1024 * 1024)
            
            logger.info(f"✓ Backup complete: {self.backup_path.name}")
            logger.info(f"  Size: {size_mb:.2f} MB")
            logger.info(f"  Duration: {duration:.2f}s")
            
            self.save_metadata()
            return True
        
        except Exception as e:
            logger.error(f"✗ Backup failed: {str(e)}")
            return False

class S3Backup:
    """Upload backups to AWS S3"""
    
    def __init__(self, bucket: str, region: str = "us-east-1"):
        """Initialize S3 backup
        
        Args:
            bucket: S3 bucket name
            region: AWS region
        """
        self.bucket = bucket
        self.s3 = boto3.client("s3", region_name=region)
        logger.info(f"S3 backup initialized: s3://{bucket}")
    
    def upload_backup(self, backup_file: Path, key_prefix: str = "") -> bool:
        """Upload backup to S3
        
        Args:
            backup_file: Path to backup file
            key_prefix: S3 key prefix (path)
            
        Returns:
            True if successful
        """
        logger.info(f"Uploading to S3: {backup_file.name}")
        
        try:
            # Construct S3 key
            s3_key = f"{key_prefix}/{backup_file.name}" if key_prefix else backup_file.name
            
            # Upload
            self.s3.upload_file(
                str(backup_file),
                self.bucket,
                s3_key,
                Callback=self._print_progress
            )
            
            logger.info(f"✓ Uploaded to S3: s3://{self.bucket}/{s3_key}")
            return True
        
        except ClientError as e:
            logger.error(f"✗ S3 upload failed: {str(e)}")
            return False
    
    def _print_progress(self, bytes_amount):
        """Progress callback for upload"""
        pass  # Can be extended to show progress

# =====================================================================
# CLI
# =====================================================================
def main():
    """CLI entry point"""
    parser = argparse.ArgumentParser(
        description="Backup Tool - Backup databases and files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Backup MySQL database
  python backup_tool.py mysql-backup --host localhost --user root --password secret --database mydb --backup-dir ./backups

  # Backup files directory
  python backup_tool.py files-backup --source /app/data --backup-dir ./backups

  # Upload to S3
  python backup_tool.py s3-upload --backup ./backups/files_data_20240205_120000.tar.gz --bucket my-backup-bucket
        """
    )
    
    subparsers = parser.add_subparsers(dest="command", help="Command to run")
    
    # MySQL backup command
    mysql_parser = subparsers.add_parser("mysql-backup", help="Backup MySQL database")
    mysql_parser.add_argument("--host", required=True, help="MySQL host")
    mysql_parser.add_argument("--user", required=True, help="MySQL user")
    mysql_parser.add_argument("--password", required=True, help="MySQL password")
    mysql_parser.add_argument("--database", required=True, help="Database name")
    mysql_parser.add_argument("--backup-dir", default="./backups", help="Backup directory")
    mysql_parser.add_argument("--retention-days", type=int, default=7, help="Retention days")
    
    # Files backup command
    files_parser = subparsers.add_parser("files-backup", help="Backup files/directory")
    files_parser.add_argument("--source", required=True, help="Source directory")
    files_parser.add_argument("--backup-dir", default="./backups", help="Backup directory")
    files_parser.add_argument("--exclude", nargs="*", help="Exclude patterns")
    files_parser.add_argument("--retention-days", type=int, default=7, help="Retention days")
    
    # S3 upload command
    s3_parser = subparsers.add_parser("s3-upload", help="Upload backup to S3")
    s3_parser.add_argument("--backup", required=True, help="Backup file path")
    s3_parser.add_argument("--bucket", required=True, help="S3 bucket")
    s3_parser.add_argument("--prefix", default="", help="S3 key prefix")
    s3_parser.add_argument("--region", default="us-east-1", help="AWS region")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    # Execute commands
    if args.command == "mysql-backup":
        backup = MySQLBackup(
            args.host,
            args.user,
            args.password,
            args.database,
            args.backup_dir
        )
        success = backup.backup()
        backup.cleanup_old_backups()
        sys.exit(0 if success else 1)
    
    elif args.command == "files-backup":
        backup = FilesBackup(
            args.source,
            args.backup_dir,
            args.exclude
        )
        success = backup.backup()
        backup.cleanup_old_backups()
        sys.exit(0 if success else 1)
    
    elif args.command == "s3-upload":
        s3 = S3Backup(args.bucket, args.region)
        success = s3.upload_backup(Path(args.backup), args.prefix)
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
