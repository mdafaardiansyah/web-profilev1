# Build stage
FROM node:18-alpine AS build

WORKDIR /app

# Copy package.json and package-lock.json first for better caching
COPY package*.json ./

# Install dependencies with error handling
RUN npm ci --no-audit || npm install --no-audit

# Copy the rest of the source code
COPY . .

# Build with ESLint warnings disabled
RUN export NODE_OPTIONS=--openssl-legacy-provider && \
    DISABLE_ESLINT_PLUGIN=true CI=false npm run build

# Production stage - using lightweight server
FROM node:18-alpine

WORKDIR /app

# Install serve
RUN npm install -g serve

# Copy built assets from the build stage
COPY --from=build /app/build /app/build

# Add a health check file
RUN mkdir -p /app/build/health && \
    echo "OK" > /app/build/health/index.html

# Health check
HEALTHCHECK --interval=30s --timeout=3s CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1

EXPOSE 3000

# Serve app with routing configuration for SPA
CMD ["serve", "-s", "build", "-l", "3000", "--cors"]