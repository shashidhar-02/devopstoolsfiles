#!/usr/bin/env bash
set -euo pipefail

USED=$(free | awk '/Mem/ {print $3/$2*100}')
awk "BEGIN {exit ($USED>85)}"
