#!/usr/bin/env bash
set -euo pipefail

PORT="$1"
ss -lnt | grep -q ":$PORT"
