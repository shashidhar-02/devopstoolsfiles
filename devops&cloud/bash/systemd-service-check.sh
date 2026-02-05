#!/usr/bin/env bash
set -euo pipefail

FAILED=$(systemctl --failed --no-legend | wc -l)
(( FAILED == 0 ))
