#!/usr/bin/env bash
set -euo pipefail

while [[ $# -gt 0 ]]; do
    case $1 in
    --env) ENV="$2"; shift ;;
    esac
    shift
done

: "${ENV:?Missing env}"
