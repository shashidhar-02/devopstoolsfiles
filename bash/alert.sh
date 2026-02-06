#!/usr/bin/env bash
set -euo pipefail

MSG="$1"
echo "$MSG" | mail -s "Server Alert" admin@example.com
