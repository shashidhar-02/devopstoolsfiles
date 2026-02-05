# Multi-stage Dockerfile for Java Applications
# Production-grade with security hardening and optimization

# =====================================================================
# STAGE 1: BUILDER - Compile Java application with Maven/Gradle
# =====================================================================
FROM maven:3.9-eclipse-temurin-17-alpine as builder

LABEL stage=builder

WORKDIR /build

# Copy pom.xml and download dependencies (cache layer)
COPY pom.xml ./
RUN mvn dependency:go-offline -q

# Copy source code
COPY src/ ./src/

# Build application (JAR file)
RUN mvn clean package -q -DskipTests && \
    mv target/*.jar app.jar && \
    rm -rf target src/ pom.xml

# =====================================================================
# STAGE 2: RUNTIME - Minimal Java runtime image
# =====================================================================
FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="devops@example.com" \
      version="1.0.0" \
      description="Production Java application" \
      org.opencontainers.image.source="https://github.com/example/app"

# Set Java runtime options
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200" \
    APP_HOME=/app \
    SPRING_PROFILES_ACTIVE=production

# Install runtime dependencies only
RUN apk add --no-cache \
    curl \
    ca-certificates \
    tini && \
    apk del apk-tools

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Set secure working directory
WORKDIR $APP_HOME

# Copy application from builder stage
COPY --from=builder --chown=appuser:appgroup /build/app.jar ./

# Create logs directory
RUN mkdir -p logs && \
    chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=40s \
            --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Use tini to handle signals properly (PID 1)
ENTRYPOINT ["/sbin/tini", "--"]

# Run Java application
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

# =====================================================================
# STAGE 3: DEBUG - Optional debug stage (multi-stage variant)
# =====================================================================
FROM builder as debug

LABEL stage=debug

# Install debugging tools
RUN apk add --no-cache \
    jdk-17.0.0 \
    vim \
    curl

# Expose debug port (JDWP)
EXPOSE 5005

# Override entrypoint for debug mode
ENV JAVA_DEBUG_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

CMD ["sh", "-c", "java $JAVA_DEBUG_OPTS $JAVA_OPTS -jar app.jar"]
