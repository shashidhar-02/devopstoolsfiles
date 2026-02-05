#!/usr/bin/env bash
set -euo pipefail

for i in {1..5}; do
    "$@" && exit 0
    sleep 2
done
exit 1
