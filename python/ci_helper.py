#!/usr/bin/env python3
"""
CI Helper - Automate CI/CD tasks and deployment validation

Demonstrates:
- REST APIs (HTTP requests to CI/CD systems)
- JSON/YAML parsing
- File I/O
- Error handling & retry logic
- CLI tools with argparse
- Kubernetes client SDK
"""

import argparse
import json
import yaml
import logging
import sys
import subprocess
from typing import Dict, List, Optional, Tuple
from pathlib import Path
from datetime import datetime
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# =====================================================================
# LOGGING SETUP
# =====================================================================
def setup_logging(log_level: str = "INFO") -> logging.Logger:
    """Configure logging"""
    logger = logging.getLogger("ci_helper")
    logger.setLevel(getattr(logging, log_level.upper()))
    
    handler = logging.StreamHandler()
    handler.setLevel(getattr(logging, log_level.upper()))
    formatter = logging.Formatter(
        '%(asctime)s - %(levelname)s - %(message)s'
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    
    return logger

logger = setup_logging(log_level="INFO")

# =====================================================================
# CI/CD BUILD HELPERS
# =====================================================================
class CIHelper:
    """Helper class for CI/CD operations"""
    
    def __init__(self, api_token: Optional[str] = None):
        """Initialize CI Helper
        
        Args:
            api_token: API token for CI/CD system (Jenkins, GitLab, etc)
        """
        self.api_token = api_token
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
        session.mount("http://", adapter)
        
        if self.api_token:
            session.headers.update({"Authorization": f"Bearer {self.api_token}"})
        
        return session
    
    # =====================================================================
    # BUILD HELPERS
    # =====================================================================
    def validate_build_artifacts(self, artifact_dir: str) -> bool:
        """Validate build artifacts exist and are valid
        
        Args:
            artifact_dir: Directory containing artifacts
            
        Returns:
            True if all artifacts valid
        """
        logger.info(f"Validating build artifacts in: {artifact_dir}")
        
        artifact_path = Path(artifact_dir)
        
        if not artifact_path.exists():
            logger.error(f"Artifact directory not found: {artifact_dir}")
            return False
        
        artifacts = list(artifact_path.glob("**/*"))
        
        if not artifacts:
            logger.error(f"No artifacts found in: {artifact_dir}")
            return False
        
        logger.info(f"✓ Found {len(artifacts)} artifacts")
        
        # Check for required files
        required_extensions = [".jar", ".war", ".zip", ".tar.gz", ".docker"]
        found_artifact = False
        
        for artifact in artifacts:
            if artifact.is_file() and any(artifact.name.endswith(ext) for ext in required_extensions):
                logger.info(f"  - {artifact.name}")
                found_artifact = True
        
        if not found_artifact:
            logger.warning("No recognized artifact types found")
        
        return True
    
    def run_tests(self, test_command: str, timeout: int = 300) -> bool:
        """Run tests with timeout
        
        Args:
            test_command: Command to run tests
            timeout: Timeout in seconds
            
        Returns:
            True if tests passed
        """
        logger.info(f"Running tests: {test_command}")
        
        try:
            result = subprocess.run(
                test_command,
                shell=True,
                timeout=timeout,
                capture_output=True,
                text=True
            )
            
            logger.info("Test output:")
            logger.info(result.stdout)
            
            if result.returncode != 0:
                logger.error(f"✗ Tests failed with return code: {result.returncode}")
                logger.error(result.stderr)
                return False
            
            logger.info("✓ Tests passed")
            return True
        
        except subprocess.TimeoutExpired:
            logger.error(f"✗ Tests timed out (>{timeout}s)")
            return False
        except Exception as e:
            logger.error(f"✗ Failed to run tests: {str(e)}")
            return False
    
    # =====================================================================
    # DEPLOYMENT VALIDATION
    # =====================================================================
    def validate_image_exists(self, registry: str, image: str, tag: str) -> bool:
        """Check if Docker image exists in registry
        
        Args:
            registry: Docker registry URL
            image: Image name
            tag: Image tag
            
        Returns:
            True if image exists
        """
        logger.info(f"Validating image: {registry}/{image}:{tag}")
        
        try:
            url = f"https://{registry}/v2/{image}/manifests/{tag}"
            
            response = self.session.head(
                url,
                timeout=10,
                headers={"Accept": "application/vnd.docker.distribution.manifest.v2+json"}
            )
            
            if response.status_code == 200:
                logger.info(f"✓ Image exists: {registry}/{image}:{tag}")
                return True
            else:
                logger.error(f"✗ Image not found: {registry}/{image}:{tag}")
                return False
        
        except Exception as e:
            logger.error(f"✗ Failed to check image: {str(e)}")
            return False
    
    def validate_k8s_deployment(self, namespace: str, deployment: str) -> bool:
        """Validate Kubernetes deployment using kubectl
        
        Args:
            namespace: Kubernetes namespace
            deployment: Deployment name
            
        Returns:
            True if deployment is ready
        """
        logger.info(f"Validating K8s deployment: {namespace}/{deployment}")
        
        try:
            # Check deployment status
            cmd = f"kubectl get deployment -n {namespace} {deployment} -o json"
            result = subprocess.run(
                cmd,
                shell=True,
                timeout=30,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                logger.error(f"✗ Deployment not found: {deployment}")
                return False
            
            deployment_data = json.loads(result.stdout)
            
            # Check replicas
            spec_replicas = deployment_data["spec"]["replicas"]
            status_replicas = deployment_data["status"].get("readyReplicas", 0)
            
            logger.info(f"Replicas: {status_replicas}/{spec_replicas}")
            
            if status_replicas >= spec_replicas:
                logger.info(f"✓ Deployment is ready: {deployment}")
                return True
            else:
                logger.error(f"✗ Deployment not fully ready")
                return False
        
        except Exception as e:
            logger.error(f"✗ Failed to validate deployment: {str(e)}")
            return False
    
    def apply_k8s_manifests(self, manifest_dir: str, namespace: str = "default", dry_run: bool = False) -> bool:
        """Apply Kubernetes manifests
        
        Args:
            manifest_dir: Directory containing YAML manifests
            namespace: Target namespace
            dry_run: If True, don't actually apply
            
        Returns:
            True if successful
        """
        logger.info(f"Applying K8s manifests from: {manifest_dir}")
        
        manifest_path = Path(manifest_dir)
        
        if not manifest_path.exists():
            logger.error(f"Manifest directory not found: {manifest_dir}")
            return False
        
        yaml_files = list(manifest_path.glob("**/*.yaml")) + list(manifest_path.glob("**/*.yml"))
        
        if not yaml_files:
            logger.error(f"No YAML files found in: {manifest_dir}")
            return False
        
        logger.info(f"Found {len(yaml_files)} manifest files")
        
        try:
            for yaml_file in yaml_files:
                logger.info(f"Processing: {yaml_file.name}")
                
                # Read and validate YAML
                with open(yaml_file, 'r') as f:
                    try:
                        yaml.safe_load_all(f)
                    except yaml.YAMLError as e:
                        logger.error(f"Invalid YAML in {yaml_file.name}: {str(e)}")
                        return False
                
                # Apply manifest
                dry_run_flag = "--dry-run=client" if dry_run else ""
                cmd = f"kubectl apply {dry_run_flag} -n {namespace} -f {yaml_file}"
                
                result = subprocess.run(
                    cmd,
                    shell=True,
                    timeout=30,
                    capture_output=True,
                    text=True
                )
                
                if result.returncode != 0:
                    logger.error(f"✗ Failed to apply {yaml_file.name}")
                    logger.error(result.stderr)
                    return False
                
                logger.info(f"✓ Applied: {yaml_file.name}")
            
            logger.info("✓ All manifests applied successfully")
            return True
        
        except Exception as e:
            logger.error(f"✗ Failed to apply manifests: {str(e)}")
            return False
    
    # =====================================================================
    # VALIDATION PIPELINE
    # =====================================================================
    def validate_deployment(self, config_file: str) -> bool:
        """Run full deployment validation pipeline
        
        Args:
            config_file: Path to validation config (YAML)
            
        Returns:
            True if all validations pass
        """
        logger.info("=" * 60)
        logger.info("DEPLOYMENT VALIDATION PIPELINE")
        logger.info("=" * 60)
        
        try:
            config_path = Path(config_file)
            
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)
            
            logger.info(f"Loaded config from: {config_file}\n")
            
            all_passed = True
            
            # Step 1: Validate artifacts
            if "artifacts" in config:
                logger.info("[1/4] Validating build artifacts...")
                if not self.validate_build_artifacts(config["artifacts"]["directory"]):
                    all_passed = False
                print()
            
            # Step 2: Validate Docker image
            if "docker_image" in config:
                logger.info("[2/4] Validating Docker image...")
                image_config = config["docker_image"]
                if not self.validate_image_exists(
                    image_config["registry"],
                    image_config["name"],
                    image_config["tag"]
                ):
                    all_passed = False
                print()
            
            # Step 3: Apply K8s manifests
            if "kubernetes" in config:
                logger.info("[3/4] Applying Kubernetes manifests...")
                k8s_config = config["kubernetes"]
                if not self.apply_k8s_manifests(
                    k8s_config["manifest_dir"],
                    k8s_config.get("namespace", "default"),
                    k8s_config.get("dry_run", False)
                ):
                    all_passed = False
                print()
            
            # Step 4: Validate K8s deployment
            if "validate_deployment" in config:
                logger.info("[4/4] Validating Kubernetes deployment...")
                deploy_config = config["validate_deployment"]
                if not self.validate_k8s_deployment(
                    deploy_config["namespace"],
                    deploy_config["name"]
                ):
                    all_passed = False
                print()
            
            logger.info("=" * 60)
            if all_passed:
                logger.info("✓ All validations passed!")
            else:
                logger.error("✗ Some validations failed!")
            logger.info("=" * 60)
            
            return all_passed
        
        except Exception as e:
            logger.error(f"✗ Validation pipeline failed: {str(e)}")
            return False
    
    def generate_validation_report(self, results: Dict, output_file: str):
        """Generate validation report
        
        Args:
            results: Validation results dictionary
            output_file: Output file path
        """
        try:
            report = {
                "timestamp": datetime.now().isoformat(),
                "results": results
            }
            
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2, default=str)
            
            logger.info(f"✓ Report saved to: {output_file}")
        
        except Exception as e:
            logger.error(f"Failed to save report: {str(e)}")

# =====================================================================
# CLI
# =====================================================================
def main():
    """CLI entry point"""
    parser = argparse.ArgumentParser(
        description="CI Helper - Validate deployments and manage CI/CD tasks",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Validate entire deployment
  python ci_helper.py validate --config deployment-validation.yaml

  # Check Docker image exists
  python ci_helper.py check-image --registry docker.io --image myapp --tag v1.0.0

  # Apply Kubernetes manifests
  python ci_helper.py apply-k8s --manifest-dir ./k8s --namespace production

  # Validate K8s deployment is ready
  python ci_helper.py check-deployment --namespace production --deployment myapp
        """
    )
    
    subparsers = parser.add_subparsers(dest="command", help="Command to run")
    
    # Validate command
    validate_parser = subparsers.add_parser("validate", help="Run full validation pipeline")
    validate_parser.add_argument(
        "--config",
        required=True,
        help="Path to validation config (YAML file)"
    )
    
    # Check image command
    image_parser = subparsers.add_parser("check-image", help="Check Docker image exists")
    image_parser.add_argument("--registry", required=True, help="Docker registry")
    image_parser.add_argument("--image", required=True, help="Image name")
    image_parser.add_argument("--tag", required=True, help="Image tag")
    
    # Apply K8s command
    k8s_parser = subparsers.add_parser("apply-k8s", help="Apply Kubernetes manifests")
    k8s_parser.add_argument(
        "--manifest-dir",
        required=True,
        help="Directory containing YAML manifests"
    )
    k8s_parser.add_argument(
        "--namespace",
        default="default",
        help="Target namespace (default: default)"
    )
    k8s_parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Dry run mode"
    )
    
    # Check deployment command
    deploy_parser = subparsers.add_parser("check-deployment", help="Check K8s deployment status")
    deploy_parser.add_argument("--namespace", required=True, help="Kubernetes namespace")
    deploy_parser.add_argument("--deployment", required=True, help="Deployment name")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    # Initialize helper
    helper = CIHelper()
    
    # Run commands
    if args.command == "validate":
        success = helper.validate_deployment(args.config)
        sys.exit(0 if success else 1)
    
    elif args.command == "check-image":
        success = helper.validate_image_exists(args.registry, args.image, args.tag)
        sys.exit(0 if success else 1)
    
    elif args.command == "apply-k8s":
        success = helper.apply_k8s_manifests(args.manifest_dir, args.namespace, args.dry_run)
        sys.exit(0 if success else 1)
    
    elif args.command == "check-deployment":
        success = helper.validate_k8s_deployment(args.namespace, args.deployment)
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
