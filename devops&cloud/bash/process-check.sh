#!/usr/bin/env bash
set -euo pipefail

PROC="$1"
pgrep -f "$PROC" >/dev/null
