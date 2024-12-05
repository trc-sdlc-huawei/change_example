# Stage 1: Build stage for assets
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy application source files
COPY . .

# Build the static assets
RUN npm run build

# Stage 2: Final image with Nginx
FROM nginx:1.25-alpine

# Set environment variables for better security
ENV TZ=UTC \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Remove the default Nginx files and configurations
RUN rm -rf /usr/share/nginx/html/* && \
    rm -rf /etc/nginx/conf.d/*

# Copy the built assets from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration file
COPY ./nginx.conf /etc/nginx/nginx.conf

# Add a health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Create a non-root user for security
RUN addgroup -g 1001 nginxuser && \
    adduser -u 1001 -G nginxuser -D nginxuser

# Adjust permissions for the non-root user
RUN chown -R nginxuser:nginxuser /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Switch to non-root user
USER nginxuser

# Optimize the container size by removing unused files
RUN apk update && apk add --no-cache \
    tini && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Use tini as the entrypoint for better signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
