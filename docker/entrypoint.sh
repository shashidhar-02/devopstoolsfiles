#!/bin/sh
#
# Docker entrypoint script
# Demonstrates:
# - Proper signal handling
# - Secrets injection
# - Configuration validation
# - Non-root execution
#

set -e  # Exit on error

# Enable strict error handling
env "${@:-.}" || true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Validate required environment variables
log_info "Validating configuration..."

required_vars=(
    "DATABASE_HOST"
    "DATABASE_PORT"
    "DATABASE_NAME"
    "DATABASE_USER"
)

for var in "${required_vars[@]}"; do
    if [ -z "$(eval echo \$$var)" ]; then
        log_error "Missing required variable: $var"
        exit 1
    fi
done

log_info "Configuration validated"

# 2. Handle secrets (mounted as files from Docker secrets or mounted volumes)
if [ -f /run/secrets/db_password ]; then
    log_info "Loading database password from secrets"
    export DATABASE_PASSWORD=$(cat /run/secrets/db_password)
elif [ -f /app/secrets/db_password.txt ]; then
    log_info "Loading database password from mounted secrets"
    export DATABASE_PASSWORD=$(cat /app/secrets/db_password.txt)
else
    log_warn "No database password found in secrets"
fi

if [ -f /run/secrets/api_key ]; then
    log_info "Loading API key from secrets"
    export API_KEY=$(cat /run/secrets/api_key)
fi

# 3. Wait for dependencies (optional)
if [ -n "$DATABASE_HOST" ]; then
    log_info "Waiting for database to be ready..."
    
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z "$DATABASE_HOST" "$DATABASE_PORT" 2>/dev/null; then
            log_info "Database is ready"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            log_error "Database failed to start after $max_attempts attempts"
            exit 1
        fi
        
        log_warn "Attempt $attempt/$max_attempts: Database not ready, retrying..."
        sleep 2
        attempt=$((attempt + 1))
    done
fi

# 4. Run database migrations (if needed)
if [ -f "/app/migrations/migrate.js" ]; then
    log_info "Running database migrations..."
    node /app/migrations/migrate.js || {
        log_error "Database migrations failed"
        exit 1
    }
fi

# 5. Health check endpoint warm-up
if [ -f "/app/src/health-check.js" ]; then
    log_info "Running health checks..."
    node /app/src/health-check.js || {
        log_warn "Health checks indicated issues, but starting anyway"
    }
fi

# 6. Print startup information (non-sensitive)
log_info "Starting application..."
log_info "Environment: ${NODE_ENV:-development}"
log_info "Database: $DATABASE_USER@$DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME"
log_info "Log Level: ${LOG_LEVEL:-info}"

# 7. Execute main command
# Using exec ensures signals are properly forwarded to child process
exec "$@"
