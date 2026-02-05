# Docker & Container Files - Production Best Practices

Comprehensive guide to production-grade Docker containers demonstrating all essential DevOps patterns.

## Overview

This module contains production-ready Docker configurations demonstrating:

| File | Purpose | Key Concepts |
|------|---------|--------------|
| **Dockerfile** | Node.js multi-stage build | JavaScript/Node.js optimization, Alpine, security |
| **Dockerfile.java** | Java multi-stage build | Maven build caching, JRE optimization, debugging |
| **docker-compose.yml** | Single dev environment | All-in-one local development setup |
| **docker-compose-dev.yml** | Three-tier development | Frontend + Backend + Database with live reload |
| **docker-compose-staging.yml** | Three-tier staging | Load balancer, backup service, resource limits |
| **docker-compose-prod.yml** | Three-tier production | HA setup, clustering, replication, monitoring |
| **.dockerignore** | Exclude unnecessary files | Build cache, layer optimization |
| **entrypoint.sh** | Container initialization | Signal handling, secrets injection, validation |
| **healthcheck.sh** | Health verification | Container liveness, readiness checks |
| **init-db.sql** | Database initialization | Schema, permissions, initial data |
| **src/server.js** | Sample Node.js app | HTTP server, metrics, graceful shutdown |

## Docker Best Practices Demonstrated

### 1. Multi-Stage Builds

**Why**: Reduces final image size by separating build tools from runtime.

**Structure**:

```dockerfile
# Stage 1: Builder (contains build tools like gcc, python, full npm)
FROM node:18-alpine as builder
RUN npm ci --only=production

# Stage 2: Runtime (minimal, no build tools)
FROM node:18-alpine
COPY --from=builder /app ./
```

**Benefits**:

- ❌ 1GB with build tools → ✅ 150MB production image
- Security: Build tools not in production (no compilation exploits)
- Layer reuse: Builder stage can be cached separately

**Example from Dockerfile**:

```dockerfile
# Stage 1: BUILDER layer
FROM node:18-alpine as builder
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: RUNTIME layer (final image)
FROM node:18-alpine
COPY --from=builder /app ./
```

### 2. Image Optimization

**Layer Caching Strategy**:

```dockerfile
# ❌ BAD: Changes source code invalidates entire layer
COPY . .
RUN npm install && npm run build

# ✅ GOOD: Dependencies cached independently
COPY package*.json ./
RUN npm ci
COPY src/ ./
RUN npm run build
```

**Alpine Images**: Use Alpine Linux (5MB base) instead of Ubuntu (77MB base)

```dockerfile
FROM node:18-alpine  # ~150MB
FROM node:18         # ~900MB
```

**Package Cleanup**:

```dockerfile
RUN apk add --no-cache curl ca-certificates && \
    apk del apk-tools  # Remove package manager itself
```

**Image Size Comparison**:

```
Single-stage Node Dockerfile:    ~900 MB
Multi-stage Alpine Dockerfile:   ~150 MB
Optimized Alpine Multi-stage:    ~80 MB
```

### 3. Security Hardening

#### Non-Root Containers

**Why**: Prevent privilege escalation if containers are compromised.

```dockerfile
# Create unprivileged user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Switch to non-root user
USER appuser
```

**Verification**:

```bash
docker run myimage whoami
# Output: appuser (not root)
```

#### Capability Dropping

```dockerfile
# Drop ALL capabilities first (most secure)
cap_drop:
  - ALL

# Add back only what's needed
cap_add:
  - NET_BIND_SERVICE  # For port binding
```

#### Security Context in docker-compose.yml

```yaml
security_opt:
  - no-new-privileges:true  # Prevent privilege escalation
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M
```

#### OCI Label Standards

```dockerfile
LABEL maintainer="devops@example.com" \
      version="1.0.0" \
      description="Production application" \
      org.opencontainers.image.source="https://github.com/..."
```

### 4. Secrets Handling

**❌ Never in Dockerfile**:

```dockerfile
# WRONG - secrets in layers (persist after container removed)
ENV PASSWORD="secret123"
RUN npm install --password=$PASSWORD
```

**✅ Secrets from files**:

```dockerfile
# Mount secrets at build time
RUN --mount=type=secret,id=npm_token \
    npm ci --token=$(cat /run/secrets/npm_token)
```

**✅ Secrets at runtime**:

```yaml
# docker-compose.yml
secrets:
  db_password:
    file: ./secrets/db_password.txt

services:
  app:
    secrets:
      - db_password
    environment:
      # Load from mounted secret file
      DATABASE_PASSWORD_FILE: /run/secrets/db_password
```

**Entrypoint injection**:

```bash
# entrypoint.sh
if [ -f /run/secrets/db_password ]; then
    export DATABASE_PASSWORD=$(cat /run/secrets/db_password)
fi

# Pass to application, never logs secrets
exec "$@"
```

### 5. Health Checks

**Docker HEALTHCHECK**:

```dockerfile
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=5s \
            --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1
```

**Parameters**:

- `--interval`: Check every 30 seconds
- `--timeout`: Fail if check takes >10 seconds
- `--start-period`: Allow 5 seconds for startup
- `--retries`: Mark unhealthy after 3 failures

**States**:

```
starting  → running 5 seconds
healthy   → passes health check
unhealthy → fails 3 consecutive checks
```

**docker-compose.yml Health Checks**:

```yaml
postgres:
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U appuser"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 10s
  depends_on:
    postgres:
      condition: service_healthy  # Wait until healthy
```

**Application Health Endpoint** (`src/server.js`):

```javascript
// GET /health - Liveness check
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

// GET /ready - Readiness check (dependencies)
app.get('/ready', (req, res) => {
    const ready = {
        database: db.isConnected,
        redis: redis.isConnected
    };
    res.status(all_ready ? 200 : 503).json(ready);
});
```

### 6. Build Cache

**Cache Layers**:

```dockerfile
# Layer 1: Base image (pulled once)
FROM node:18-alpine

# Layer 2: Dependencies (cached until package*.json changes)
COPY package*.json ./
RUN npm ci

# Layer 3: Source code (invalidated on every source change)
COPY src/ ./

# Layer 4: Final setup (runs after source change)
RUN npm run build
```

**Cache Hit vs Miss**:

```
$ docker build .
Step 1/4 : FROM node:18-alpine
 ---> [cached]     # Hit: base unchanged
Step 2/4 : COPY package*.json ./
 ---> [using cache] # Hit: dependencies unchanged
Step 3/4 : COPY src/ ./
 ---> [new]       # Miss: source code changed
Step 4/4 : RUN npm run build
 ---> [running]   # Runs: source layer invalidated cache
```

**Buildkit Cache**:

```bash
# Enable BuildKit for better caching
DOCKER_BUILDKIT=1 docker build .

# Use cache from registry
docker build \
  --cache-from myregistry.azurecr.io/app:latest \
  -t myapp:latest .
```

### 7. Image Scanning

**Built-in in docker-compose.yml**:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: ./Dockerfile
      # Scan for vulnerabilities
      args:
        SCAN: "true"
```

**Tools**:

**Trivy** (recommended):

```bash
# Scan image for vulnerabilities
trivy image myregistry.azurecr.io/app:latest

# Generate report
trivy image --format json --output report.json myapp:latest

# Severity filtering
trivy image --severity HIGH,CRITICAL myapp:latest
```

**Docker Scout**:

```bash
# Built-in to Docker Desktop
docker scout cves myapp:latest
docker scout cves --format json myapp:latest
```

**Sample output**:

```
myapp:latest (vulnerabilities)
Found 4 vulnerabilities
HIGH (3)
  OpenSSL 1.1.1 - CVE-2022-0778
  expat - CVE-2022-23990
MEDIUM (1)
  libcurl - CVE-2022-27775
```

### 8. OCI Standards Compliance

**OCI Image Spec Labels**:

```dockerfile
LABEL org.opencontainers.image.created="2024-02-05T12:00:00Z" \
      org.opencontainers.image.authors="DevOps Team" \
      org.opencontainers.image.url="https://github.com/example/app" \
      org.opencontainers.image.documentation="https://docs.example.com" \
      org.opencontainers.image.source="https://github.com/example/app" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.revision="abc123" \
      org.opencontainers.image.vendor="Example Corp" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="Example App" \
      org.opencontainers.image.description="Production app"
```

**Runtime Configuration**:

```dockerfile
# OCI standard runtime format
USER 1001:1001  # uid:gid
WORKDIR /app
ENTRYPOINT ["/usr/sbin/dumb-init", "--"]
CMD ["node", "/app/src/server.js"]
```

---

## Dockerfile Comparison

### Node.js vs Java Applications

| Aspect | Node.js (Dockerfile) | Java (Dockerfile.java) |
|--------|-----------------|---------------------|
| **Build Tool** | npm | Maven (build cache) |
| **Base Images** | node:18-alpine | maven:3.9-alpine → eclipse-temurin:17-jre-alpine |
| **Build Time** | ~30 seconds | ~2-3 minutes (Maven) |
| **Final Size** | ~150 MB | ~250 MB |
| **Runtime** | Node.js script | Java JVM process |
| **Debug Port** | None by default | 5005 (JDWP) available |
| **Dependencies** | npm modules | Maven JAR files |
| **Health Check** | HTTP endpoint | Spring Boot Actuator |

### Node.js Dockerfile (Dockerfile)

```dockerfile
# Multi-stage: Builder → Runtime
FROM node:18-alpine as builder
# npm ci install only production dependencies

FROM node:18-alpine
# Non-root user, health checks
# ~150 MB final image

# Usage:
docker build -t frontend:latest .
docker run -p 3000:3000 frontend:latest
```

### Java Dockerfile (Dockerfile.java)

```dockerfile
# Multi-stage: Maven Builder → JRE Runtime → Debug Stage
FROM maven:3.9-eclipse-temurin-17-alpine as builder
# mvn dependency:go-offline (cache)
# mvn clean package

FROM eclipse-temurin:17-jre-alpine
# SPRING_PROFILES_ACTIVE, JAVA_OPTS
# Health checks for Spring Boot Actuator
# ~250 MB final image

# Usage:
docker build -f Dockerfile.java -t backend:latest .
docker run -p 8080:8080 -p 5005:5005 backend:latest

# Debug with IDE
# In IntelliJ/VSCode: Debug → Remote Application → localhost:5005
```

### Key Differences

**Node.js Advantages:**

- Faster build time (~30s)
- Smaller image size (~150 MB)
- Simple dependency management
- Ideal for microservices

**Java Advantages:**

- Built-in dependency isolation (JAR files)
- Type safety at compile time
- Spring Boot Actuator for production health checks
- Better for enterprise applications
- Debug support (JDWP) built-in

### Example Deployments

**Frontend (Node.js)**:

```bash
# Single container, stateless
docker run -d \
  -p 3000:3000 \
  -e REACT_APP_API_URL=https://api.example.com \
  frontend:latest
```

**Backend (Java)**:

```bash
# Connect to database and cache
docker run -d \
  -p 8080:8080 \
  -p 5005:5005 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/app \
  -e SPRING_REDIS_HOST=redis \
  -e SPRING_PROFILES_ACTIVE=production \
  backend:latest
```

## Three-Tier Architecture

Three separate docker-compose files for different environments, demonstrating scalability:

### Architecture Overview

```
         ┌─────────────────────────────────┐
         │     PRESENTATION LAYER          │
         │  Frontend (React/Vue/Angular)   │
         │  - Web UI, Static Assets        │
         └─────────────────────────────────┘
                        ↓
         ┌─────────────────────────────────┐
         │    APPLICATION LAYER            │
         │  Backend (Java Spring Boot)     │
         │  - Business Logic, APIs         │
         │  - Cache (Redis)                │
         └─────────────────────────────────┘
                        ↓
         ┌─────────────────────────────────┐
         │     DATA LAYER                  │
         │  Database (PostgreSQL)          │
         │  - Persistent Storage           │
         │  - Replication (Production)     │
         └─────────────────────────────────┘
```

### docker-compose-dev.yml - Development

**Setup:** Frontend (React dev) → Backend (Java debug) → Database

**Features:**

- Live reload for frontend (volume mounts)
- Debug port for Java (5005)
- No port restrictions (all exposed)
- Database exposed for CLI access
- Maven cache shared

**Usage:**

```bash
docker-compose -f docker-compose-dev.yml up -d

# View logs
docker-compose -f docker-compose-dev.yml logs -f backend

# Access services
curl http://localhost:3000        # Frontend
curl http://localhost:8080/api    # Backend
psql -h localhost -U devuser      # Database
```

**Services:**

- `frontend` - React (port 3000) with live reload
- `backend` - Java Spring Boot (port 8080 + debug 5005)
- `database` - PostgreSQL (port 5432)

### docker-compose-staging.yml - Staging

**Setup:** Nginx LB → Frontend (2 replicas) → Backend (1) → Database + Backup

**Features:**

- Load balancer (Nginx) for high availability
- Production builds (no debug, optimized)
- Health checks enforced
- Backup service (automated daily)
- Resource limits enforced
- Secrets management
- No exposed database port
- Logging to file

**Usage:**

```bash
# Copy example file and fill in secrets
cp .env.example .env.staging
cp secrets/db_password.txt.example secrets/db_password.txt

# Start services
docker-compose -f docker-compose-staging.yml up -d

# View status
docker-compose -f docker-compose-staging.yml ps

# Check health
curl -k https://localhost/health

# Scale backend
docker-compose -f docker-compose-staging.yml up -d --scale backend=2
```

**Services:**

- `load-balancer` - Nginx reverse proxy (port 80/443)
- `frontend` - Production React (2 replicas behind LB)
- `backend` - Java API
- `database` - PostgreSQL
- `backup` - Automated backup service

### docker-compose-prod.yml - Production

**Setup:** Nginx LB → Frontend (2) → Backend cluster (3) → PostgreSQL (Master + Replica) + Redis + Monitoring

**Features:**

- High availability (multiple replicas)
- Load balancing for all tiers
- PostgreSQL Master-Replica replication
- Redis caching layer
- Prometheus + Grafana monitoring
- AWS CloudWatch logging
- Resource limits strictly enforced
- No exposed service ports
- Automated backups + replication
- JWT authentication
- CORS and security hardening

**Usage:**

```bash
# Set up secrets from AWS Secrets Manager or secure vault
export SENTRY_DSN=$(aws secretsmanager get-secret-value --secret-id sentry-dsn --query 'SecretString' --output text)
export ANALYTICS_ID=$(aws secretsmanager get-secret-value --secret-id analytics-id --query 'SecretString' --output text)

# Start production stack
docker-compose -f docker-compose-prod.yml up -d

# Monitor with Grafana
curl http://localhost:3001  # Grafana dashboard

# View metrics
curl http://localhost:9090  # Prometheus

# Check service health
docker-compose -f docker-compose-prod.yml ps

# View logs (streaming)
docker-compose -f docker-compose-prod.yml logs -f backend-1 backend-2 backend-3
```

**Services:**

- `load-balancer` - Nginx with SSL (port 80/443)
- `frontend` - Production React (2 replicas)
- `backend-1/2/3` - Java API cluster (3 instances)
- `redis` - Session & data caching
- `database-master` - PostgreSQL writer
- `database-replica` - PostgreSQL read replica
- `prometheus` - Metrics collection
- `grafana` - Monitoring dashboards

**Cluster Architecture:**

```
┌─ Master (write)
└─ Replica (read) for load distribution

Backend instances:
├─ backend-1 (1.5 CPU, 1.5 GB)
├─ backend-2 (1.5 CPU, 1.5 GB)
└─ backend-3 (1.5 CPU, 1.5 GB)
```

## Usage Examples

### Building Images

**Standard build**:

```bash
# Build Node.js image
docker build -t myapp:1.0.0 .

# Build Java image
docker build -f Dockerfile.java -t myapp-java:1.0.0 .

# Build with build arguments
docker build \
  --build-arg VERSION=1.0.0 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  -t myapp:1.0.0 .

# Build specific stage (debug)
docker build --target debug -t myapp:debug .
```

**Java-Specific Build**:

```bash
# Build Java image with fast rebuild (cached dependencies)
docker build \
  -f Dockerfile.java \
  -t backend-api:1.0.0 .

# View Maven build layers and cache efficiency
docker history backend-api:1.0.0

# Build debug stage for IDE debugging
docker build \
  -f Dockerfile.java \
  --target debug \
  -t backend-api:debug .

# Run Java app locally
docker run \
  -p 8080:8080 \
  -p 5005:5005 \
  -e SPRING_PROFILES_ACTIVE=development \
  backend-api:debug
```

**BuildKit with caching**:

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Use cache from registry
docker build \
  --cache-from myregistry.azurecr.io/app:latest \
  -t myregistry.azurecr.io/app:1.0.0 .

# Push to registry
docker push myregistry.azurecr.io/app:1.0.0
```

### Running Containers

**Basic run**:

```bash
docker run -p 3000:3000 myapp:latest
```

**With environment and secrets**:

```bash
docker run \
  -e DATABASE_HOST=postgres \
  -e DATABASE_NAME=mydb \
  -e DATABASE_USER=appuser \
  --secret db_password \
  --secret api_key \
  -p 3000:3000 \
  myapp:latest
```

**With volume mounts**:

```bash
docker run \
  -v /app/logs:$(pwd)/logs \
  -v /app/config.yaml:$(pwd)/config.yaml:ro \
  myapp:latest
```

### Using Docker Compose

**Start services**:

```bash
# Basic development (all-in-one)
docker-compose up -d

# Start with environment file
docker-compose --env-file .env.production up -d

# Three-tier architecture options
# Development environment (live reload, debugging)
docker-compose -f docker-compose-dev.yml up -d

# Staging environment (load balancer, backups)
docker-compose -f docker-compose-staging.yml up -d

# Production environment (HA, replication, monitoring)
docker-compose -f docker-compose-prod.yml up -d

# Scale service (production)
docker-compose -f docker-compose-prod.yml up -d --scale backend=5

# View logs
docker-compose logs -f app
docker-compose -f docker-compose-prod.yml logs -f backend-1 backend-2 backend-3

# Health status
docker-compose ps
# NAME                STATUS
# devops-app          Up 1 minute (healthy)
# devops-postgres     Up 1 minute (healthy)
# devops-redis        Up 1 minute
```

**Development Workflow**:

```bash
# Start dev environment with live code reload
docker-compose -f docker-compose-dev.yml up -d

# View logs in real-time
docker-compose -f docker-compose-dev.yml logs -f backend

# Attach Java debugger to IDE (port 5005)
# In IDE: Run → Debug → Remote Application → localhost:5005

# Make code changes (automatically reloaded for React)
vi src/main/java/com/example/App.java

# Rebuild Java application
docker-compose -f docker-compose-dev.yml down
docker-compose -f docker-compose-dev.yml up -d
```

**Stop and cleanup**:

```bash
# Stop containers
docker-compose down
docker-compose -f docker-compose-dev.yml down

# Remove volumes
docker-compose down -v

# Remove images
docker-compose down --rmi all

# Clean up all containers from three-tier stack
docker-compose -f docker-compose-prod.yml down -v
```

### Secrets Management

**Local secrets (development)**:

```bash
# Create secret files
mkdir secrets
echo "mysecretpassword" > secrets/db_password.txt
echo "my-api-key-xyz" > secrets/api_key.txt

# Run with secrets
docker-compose up
```

**Staging secrets**:

```bash
# Copy example and fill in values
cp .env.example .env.staging
cp secrets/db_password.txt.example secrets/staging_db_password.txt

# Generate strong passphrase
openssl rand -base64 32 > secrets/staging_db_password.txt

# Start with secrets
docker-compose -f docker-compose-staging.yml up -d
```

**Production secrets (from AWS/Azure)**:

```bash
# Load secrets from AWS Secrets Manager
export DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id prod/db/password \
  --query SecretString \
  --output text)

export JWT_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id prod/jwt/secret \
  --query SecretString \
  --output text)

# Start production stack
docker-compose -f docker-compose-prod.yml up -d
```

**Docker Swarm secrets (production)**:

```bash
# Create secret
echo "mysecretpassword" | docker secret create db_password -

# Use in compose
secrets:
  db_password:
    external: true
```

### Connecting to Services

**Frontend (React)**:

```bash
# Development
curl http://localhost:3000

# Staging
curl -k https://localhost

# Production
curl https://api.example.com
```

**Backend API**:

```bash
# Development
curl http://localhost:8080/api/health

# Staging  
curl http://localhost:8080/api/actuator/health

# Production (behind LB)
curl https://api.example.com/api/actuator/health
```

**Database CLI**:

```bash
# Development
docker-compose -f docker-compose-dev.yml exec database psql -U devuser -d devdb

# View logs
docker-compose -f docker-compose-dev.yml logs database
```

**Redis Cache**:

```bash
# Connect to Redis in staging/prod
docker-compose -f docker-compose-staging.yml exec redis redis-cli
redis-cli> PING
redis-cli> KEYS *
redis-cli> GET session:abc123
```

**Monitoring (Production)**:

```bash
# Prometheus metrics
curl http://localhost:9090

# Grafana dashboards
curl http://localhost:3001

# Backend metrics endpoint
curl http://localhost:8080/actuator/prometheus
```

**Kubernetes secrets (production)**:

```bash
# Create secret
kubectl create secret generic db-password \
  --from-file=password=secrets/db_password.txt

# Reference in pod
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-password
        key: password
```

## Performance Optimization

### Image Layer Optimization

**Dockerfile.optimized**:

```dockerfile
# 1. Use specific base image versions
FROM node:18.17.1-alpine3.18  # Not :18-alpine (floating tag)

# 2. Combine RUN commands to reduce layers
RUN apk add --no-cache curl ca-certificates && \
    npm ci --only=production && \
    npm cache clean --force

# 3. Use .dockerignore to exclude files
# See .dockerignore file

# 4. Multi-stage builds reduce final size
COPY --from=builder /app /app

# 5. Avoid unnecessary ownership changes
COPY --chown=appuser:appgroup /app /app
```

### Build Performance

**Metrics**:

```
No cache:              45 seconds
With cache:            2 seconds (100x faster!)
Multi-stage Alpine:    25 MB final size
Full single-stage:     900 MB
```

**Optimization checklist**:

- [ ] Use Alpine as base image
- [ ] Order Dockerfile commands (dependencies → source code)
- [ ] Combine RUN statements
- [ ] Use docker-compose.yml caching
- [ ] Exclude unnecessary files (.dockerignore)
- [ ] Pin base image versions
- [ ] Use .dockerignore for build context

### Runtime Performance

**Resource limits** (docker-compose.yml):

```yaml
deploy:
  resources:
    # Hard limit (OOM kills if exceeded)
    limits:
      cpus: '1.0'       # 1 CPU core
      memory: 512M      # 512 MB RAM
    
    # Soft limit (requested amount)
    reservations:
      cpus: '0.5'       # 0.5 CPU core
      memory: 256M      # 256 MB RAM
```

**Logging optimization**:

```yaml
logging:
  driver: json-file    # Default, space efficient
  options:
    max-size: "10m"    # Rotate at 10 MB
    max-file: "3"      # Keep 3 files (30 MB total)
    labels: "service=app"  # Add metadata
```

## Troubleshooting

### Common Issues

**Issue: Image too large**

```bash
# Solution: Use Alpine and multi-stage
docker history myapp:latest  # View layer sizes
docker image ls --format "{{.Size}}" myapp:latest
```

**Issue: Secrets visible in build history**

```bash
# ❌ Wrong: Clear in history
docker build --build-arg PASSWORD=secret .

# ✅ Right: Use mount secrets
docker build --secret npm_token=~/.npm/token .
RUN --mount=type=secret,id=npm_token npm ci
```

**Issue: Health check failing**

```bash
# Check logs
docker-compose logs app

# Test manually
docker exec <container> curl http://localhost:3000/health

# Debug
docker run -it myapp:latest sh
```

**Issue: Permission denied (appuser)**

```bash
# Check user
docker run myapp:latest whoami

# Fix dockerfile
USER appuser  # Ensure user created first
RUN chmod +x ./entrypoint.sh
```

## Advanced Topics

### Image Signing

```bash
# Sign image
docker trust sign myregistry.azurecr.io/app:1.0.0

# Verify signature when pulling
export DOCKER_CONTENT_TRUST=1
docker pull myregistry.azurecr.io/app:1.0.0
```

### Registry Integration

```bash
# Scan on push to Docker Hub
docker push myapp:latest
# Runs automatic vulnerability scanning

# Azure Container Registry
az acr build \
  --registry myregistry \
  --image myapp:{{.Run.ID}} .

# Google Container Registry
gcloud builds submit \
  --tag gcr.io/project/myapp:latest .
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: app
        image: myregistry.azurecr.io/app:1.0.0
        imagePullPolicy: IfNotPresent
        
        # Liveness check (restart if unhealthy)
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        
        # Readiness check (remove from load balancer)
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

## Checklist for Production

- [ ] Multi-stage build reduces final image size
- [ ] Non-root user (USER directive)
- [ ] Health checks configured
- [ ] Secrets managed (not in ENV)
- [ ] Resource limits set
- [ ] Image scanned for vulnerabilities
- [ ] Logging configured with rotation
- [ ] Docker Hub or registry integration
- [ ] Security options configured
- [ ] OCI labels added
- [ ] .dockerignore excludes unnecessary files
- [ ] Entrypoint handles signals (dumb-init)
- [ ] All base images pinned to versions
- [ ] Documentation updated

## References

- **OCI Image Spec**: <https://github.com/opencontainers/image-spec>
- **Docker Best Practices**: <https://docs.docker.com/develop/dev-best-practices/>
- **Trivy Scanning**: <https://github.com/aquasecurity/trivy>
- **Docker Compose Spec**: <https://docs.docker.com/compose/compose-file/>
