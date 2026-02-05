#!/bin/sh
#
# Health check script for Docker health monitoring
# Verifies application is running and responsive
#
# Usage:
#   docker healthcheck call <container-id>
#   curl http://localhost:3000/health
#

set -e

HOST="${1:-localhost}"
PORT="${2:-3000}"
TIMEOUT="${3:-5}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if curl is available
if ! command -v curl &> /dev/null; then
    log_error "curl is not available"
    exit 1
fi

# Perform health check
log_info "Checking health: $HOST:$PORT"

response=$(curl -f \
    --silent \
    --connect-timeout $TIMEOUT \
    --max-time $TIMEOUT \
    -w "\n%{http_code}" \
    "http://$HOST:$PORT/health" 2>/dev/null || echo "000")

http_code=$(echo "$response" | tail -n1)
status=$(echo "$response" | head -n-1)

# Evaluate response
if [ "$http_code" = "200" ]; then
    log_info "Health check passed (HTTP $http_code)"
    
    # Optional: parse JSON response
    if echo "$status" | grep -q '"status":"healthy"'; then
        log_info "Application status: healthy"
        exit 0
    elif echo "$status" | grep -q '"status":"ready"'; then
        log_info "Application status: ready"
        exit 0
    else
        log_error "Unexpected response: $status"
        exit 1
    fi
else
    log_error "Health check failed (HTTP $http_code)"
    exit 1
fi
