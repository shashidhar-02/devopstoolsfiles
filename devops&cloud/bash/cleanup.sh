#!/usr/bin/env bash
set -euo pipefail

trap 'echo "Interrupted"; exit 2' SIGINT SIGTERM

find /tmp -type f -mtime +7 -delete
echo "Cleanup completed at $(date)"
