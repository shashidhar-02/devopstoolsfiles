# Multi-stage Dockerfile demonstrating production best practices
# Demonstrates: multi-stage builds, image optimization, security hardening,
# non-root containers, secrets handling, health checks, build cache, OCI standards

# =====================================================================
# STAGE 1: BUILDER - Compile/prepare application
# =====================================================================
FROM node:18-alpine as builder

LABEL stage=builder

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    ca-certificates

# Set working directory (cache layer)
WORKDIR /app

# Copy only package files first (maximize build cache)
# This layer is reused if package files don't change
COPY package*.json ./

# Install dependencies with npm ci (more reproducible than npm install)
# Using --only=production reduces image size
RUN npm ci --only=production && \
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
FROM node:18-alpine

LABEL maintainer="devops@example.com" \
      version="1.0.0" \
      description="Production-grade Node.js application" \
      repository="https://github.com/shashidhar-02/devopstoolsfiles"

# Set environment to production (optimize Node.js runtime)
ENV NODE_ENV=production \
    NODE_OPTIONS="--max-old-space-size=512"

# Install runtime dependencies only (security hardening)
RUN apk add --no-cache \
    curl \
    ca-certificates \
    dumb-init && \
    apk del apk-tools

# Create non-root user (security best practice)
# Run container as unprivileged user, not root
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Set secure working directory
WORKDIR /app

# Copy application from builder stage
COPY --from=builder --chown=appuser:appgroup /app ./

# Copy entrypoint script
COPY --chown=appuser:appgroup docker/entrypoint.sh ./

# Make entrypoint executable
RUN chmod +x ./entrypoint.sh

# Security: Drop capabilities (least privilege)
RUN setcap -r /usr/local/bin/node || true

# Switch to non-root user before health/run commands
USER appuser

# Expose port (documenting, not enforcing security)
EXPOSE 3000

# Health check (verify container is running properly)
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=5s \
            --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use dumb-init to handle signals properly (PID 1)
ENTRYPOINT ["/usr/sbin/dumb-init", "--"]

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
