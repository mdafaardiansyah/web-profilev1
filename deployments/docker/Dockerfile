# Build stage
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Set Node options untuk mengatasi masalah OpenSSL
ENV NODE_OPTIONS=--openssl-legacy-provider

# Copy source files and build the application
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx /var/lib/nginx && \
    chmod -R 777 /var/cache/nginx /var/run /var/log/nginx /var/lib/nginx /usr/share/nginx/html

# Copy custom nginx config
COPY deployments/docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copy build files from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Expose port
EXPOSE 3000

# Configure nginx to run on port 3000
RUN sed -i 's/listen\s*80/listen 3000/g' /etc/nginx/conf.d/default.conf

# Health check
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q --spider http://localhost:3000/ || exit 1

CMD ["nginx", "-g", "daemon off;"]