#!/usr/bin/env bash
set -euo pipefail

LOG="/var/log/app.log"
mv "$LOG" "$LOG.$(date +%F)"
gzip "$LOG".*