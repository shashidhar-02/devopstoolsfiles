#!/usr/bin/env bash
set -euo pipefail

SERVICE="nginx"
PORT=80
LOG="/var/log/health.log"

exec >>"$LOG" 2>&1

systemctl is-active --quiet "$SERVICE"
ss -lnt | grep -q ":$PORT"

MEM=$(free -m | awk '/Mem/ {print $3}')
(( MEM < 8000 ))

echo "$(date) | System healthy"
