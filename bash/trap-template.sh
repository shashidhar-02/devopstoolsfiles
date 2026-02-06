#!/usr/bin/env bash
set -euo pipefail

cleanup() {
    echo "Cleaning resources"
}
trap cleanup EXIT ERR SIGINT SIGTERM
