#!/usr/bin/env bash
set -euo pipefail

PORT="$1"
PID=$(lsof -ti :"$PORT")
kill -9 "$PID"
