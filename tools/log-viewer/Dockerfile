# 📊 TRIVANCE LOG VIEWER - Dockerfile
# Observability service for unified logging

FROM node:22-alpine

# Install system dependencies
RUN apk add --no-cache curl bash

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Expose port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:4000/health || exit 1

# Start application
CMD ["node", "server.js"]