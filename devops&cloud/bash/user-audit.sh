#!/usr/bin/env bash
set -euo pipefail

lastlog
awk -F: '$3>=1000 {print $1}' /etc/passwd
