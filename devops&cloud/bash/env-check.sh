#!/usr/bin/env bash
set -euo pipefail

VARS=(DB_HOST DB_USER DB_PASS)

for v in "${VARS[@]}"; do
    : "${!v:?Missing $v}"
done
