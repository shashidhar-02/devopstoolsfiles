#!/usr/bin/env bash
set -euo pipefail

THRESHOLD=80
USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

(( USAGE < THRESHOLD ))
