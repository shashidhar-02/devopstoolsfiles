#!/usr/bin/env bash
set -euo pipefail

HOST="$1"
: "${HOST:?Host required}"

ssh "$HOST" <<EOF
uptime
df -h /
free -m
systemctl is-active docker
EOF
