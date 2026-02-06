#!/usr/bin/env bash
set -euo pipefail

LOG="/var/log/deploy.log"
exec >>"$LOG" 2>&1

while getopts h:a: opt; do
    case $opt in
    h) HOST="$OPTARG" ;;
    a) APP_DIR="$OPTARG" ;;
    *) exit 1 ;;
    esac
done

: "${HOST:?Missing host}"
: "${APP_DIR:?Missing app dir}"

ssh "$HOST" <<EOF
    set -e
    cd "$APP_DIR"
    git pull
    systemctl restart app.service
EOF

echo "$(date) | Deployment successful"
