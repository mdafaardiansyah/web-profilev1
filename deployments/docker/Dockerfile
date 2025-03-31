# Build stage
FROM node:18-alpine AS build

# Set Node options for legacy dependencies if needed
ENV NODE_OPTIONS=--openssl-legacy-provider

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies with CI=false to ignore errors
RUN npm ci --legacy-peer-deps || npm install --legacy-peer-deps

# Copy the rest of the application
COPY . .

# Set environment variables for build
ENV DISABLE_ESLINT_PLUGIN=true
ENV CI=false
ENV SKIP_PREFLIGHT_CHECK=true

# Build application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built assets from the build stage
COPY --from=build /app/build /usr/share/nginx/html

# Add custom nginx config
COPY deployments/docker/nginx.conf /etc/nginx/conf.d/default.conf

# Create health check endpoint file
RUN echo "healthy" > /usr/share/nginx/html/health

# Add health check for kubernetes
HEALTHCHECK --interval=30s --timeout=3s CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# Expose port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]