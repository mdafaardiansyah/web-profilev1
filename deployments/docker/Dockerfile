# Build stage
FROM node:18-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage - using lightweight server instead of nginx
FROM node:18-alpine

WORKDIR /app

# Install lightweight server
RUN npm install -g serve

# Copy built assets from the build stage
COPY --from=build /app/build /app/build

# Health check for kubernetes
HEALTHCHECK --interval=30s --timeout=3s CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1

EXPOSE 3000

# Serve app with routing configuration for SPA
CMD ["serve", "-s", "build", "-l", "3000", "--cors"]