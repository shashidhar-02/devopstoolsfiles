#!/usr/bin/env bash
set -euo pipefail

JOB="0 1 * * * /opt/scripts/backup.sh"

(crontab -l 2>/dev/null; echo "$JOB") | sort -u | crontab -
echo "$(date) | Cron job added: $JOB"
