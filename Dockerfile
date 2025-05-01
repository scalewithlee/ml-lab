# syntax=docker/dockerfile:1.0
FROM python:3.13-alpine AS builder

# Install build deps
RUN apk add --no-cache gcc g++ musl-dev linux-headers

WORKDIR /build

# Copy and install python deps
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.13-alpine

# Copy deps from builder
COPY --from=builder /install /usr/local

WORKDIR /app

# Configure prefect
RUN prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api

# Expose port for prefect API and health check server
EXPOSE 4200 8080

# Flush output immediately
ENV PYTHONUNBUFFERED=1

# Set log level
ENV LOG_LEVEL=INFO

# Install monitoring deps
RUN apk add --no-cache curl

# Create a healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period= --retries=3 \
    CMD curl -f http://localhost:8080/health/liveness || exit 1

# Copy source code
COPY src/ /app/
COPY scripts/ /app/scripts/
RUN chmod +x /app/scripts/entrypoint.sh

# Default command
ENTRYPOINT ["/app/scripts/entrypoint.sh"]
CMD ["prefect", "server", "start"]
