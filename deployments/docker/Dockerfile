FROM node:18-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
# Buat direktori yang dibutuhkan dan berikan permissions yang tepat
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx /var/lib/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/run /var/log/nginx /var/lib/nginx /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build files
COPY --from=build /app/build /usr/share/nginx/html

# Expose port
EXPOSE 3000

# Configure nginx to run on port 3000
RUN sed -i 's/listen\s*80/listen 3000/g' /etc/nginx/conf.d/default.conf

# Run as non-root user
USER nginx

CMD ["nginx", "-g", "daemon off;"]