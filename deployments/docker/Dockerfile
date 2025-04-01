# Stage 1 - Builder (Build sudah dilakukan di Jenkinsfile, jadi kita langsung serve)
FROM nginx:alpine

# Copy the React build
COPY build/ /usr/share/nginx/html

# Copy custom nginx config
COPY deployments/docker/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]