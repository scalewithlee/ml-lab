# syntax=docker/dockerfile:1.0
FROM python:3.13-alpine AS builder

# Install build deps
RUN apk add --no-cache gcc g++ musl-dev

WORKDIR /build

# Copy and install python deps
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.13-alpine

# Copy deps from builder
COPY --from=builder /install /usr/local

WORKDIR /code

# Configure prefect
RUN prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api

# Expose port for prefect API
EXPOSE 4200

# Flush output immediately
ENV PYTHONUNBUFFERED=1

# Copy source code
COPY pipelines .

# Run it!
CMD ["sh"]
