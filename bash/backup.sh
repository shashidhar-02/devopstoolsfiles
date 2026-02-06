#!/usr/bin/env bash
set -euo pipefail

SRC="/data"
DEST="/backups"
DATE=$(date +%F)
LOG="/var/log/backup.log"

exec >>"$LOG" 2>&1

df "$DEST" | awk 'NR==2 {exit ($4<1048576)}'

tar -czf "$DEST/backup-$DATE.tar.gz" "$SRC"

echo "$(date) | Backup completed"
