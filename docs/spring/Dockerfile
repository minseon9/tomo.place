# Multi-stage build for optimization
FROM gradle:8.14.2-jdk21 AS builder

WORKDIR /app

# Copy tomo gradle project (전체 멀티프로젝트)
COPY tomo/ ./

# Build the specific subproject 'b'
RUN gradle build --no-daemon -x test

# Runtime stage
FROM openjdk:21-jdk

WORKDIR /app

# Create non-root user for security
RUN groupadd -r spring && useradd -r -g spring spring

COPY --from=builder /app/tomo/build/libs/*.jar app.jar

# Change ownership to spring user
RUN chown -R spring:spring /app

# Switch to non-root user
USER spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
