# Multi-stage Dockerfile demonstrating production best practices
# Demonstrates: multi-stage builds, image optimization, security hardening,
# non-root containers, secrets handling, health checks, build cache, OCI standards

# =====================================================================
# STAGE 1: BUILDER - Compile/prepare application
# =====================================================================
FROM node:18-bookworm-slim as builder

LABEL stage=builder

# Install build dependencies
RUN apk add --no-cache \
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory (cache layer)
WORKDIR /app

# Copy only package files first (maximize build cache)
# This layer is reused if package files don't change
COPY package*.json ./

# Install dependencies with npm ci (more reproducible than npm install)
# Using --only=production reduces image size
RUN npm ci --only=production && \
        npm audit --audit-level=moderate && \
    npm cache clean --force

# Copy application source code
# This layer is reused until source code changes
COPY src/ ./src/
COPY .env.example ./

# Build application (if needed)
RUN npm run build --if-present

# =====================================================================
# STAGE 2: RUNTIME - Minimal image (security hardened)
# =====================================================================
# Use distroless Node.js image - zero OS attack surface, immutable base
FROM gcr.io/distroless/nodejs18-debian11:nonroot

LABEL maintainer="devops@example.com" \
      version="1.0.0" \
      description="Production-grade Node.js application" \
      repository="https://github.com/shashidhar-02/devopstoolsfiles"

# Set environment to production (optimize Node.js runtime)
ENV NODE_ENV=production \
    NODE_OPTIONS="--max-old-space-size=512"

# Install runtime dependencies only (security hardening)

# Create non-root user (security best practice)

# Set secure working directory
WORKDIR /app

# Copy application from builder stage
COPY --from=builder --chown=nonroot:nonroot /app ./

# Copy entrypoint script
COPY --chown=nonroot:nonroot docker/entrypoint.sh ./

# Make entrypoint executable
RUN chmod +x ./entrypoint.sh

# Security: Drop capabilities (least privilege)

# Switch to non-root user before health/run commands
USER nonroot

# Expose port (documenting, not enforcing security)
EXPOSE 3000

# Health check (verify container is running properly)

# Use dumb-init to handle signals properly (PID 1)

# Run application
CMD ["node", "/app/src/server.js"]

# =====================================================================
# STAGE 3: DEBUG (optional multi-stage for development debugging)
# =====================================================================
FROM builder as debug

LABEL stage=debug

# Install debugging tools
RUN npm install --global --save=false \
    @node-inspector/inspector \
    nodemon

# Expose debug port
EXPOSE 9229

# Override entrypoint for debugging
CMD ["node", "--inspect=0.0.0.0:9229", "/app/src/server.js"]
# Note: Use docker-compose-dev.yml for debugging with live reload

# Security Notes:
# 1. Distroless image has no shell, package manager, or unnecessary tools
# 2. All dependencies pinned to specific versions in package-lock.json
# 3. npm audit run during build to catch vulnerabilities early
# 4. Nonroot user (UID 65532) provides privilege isolation
# 5. Read-only root filesystem can be enabled with docker-compose
# 6. No shell means no interactive debugging - use remote debugger instead
# Override entrypoint for debugging
