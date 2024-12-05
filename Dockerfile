# Use a base image with root privileges
FROM ubuntu:latest

# Update and install everything without locking versions
RUN apt-get update && apt-get install -y nginx curl && \
    apt-get clean

# Allow execution of any script in the container
COPY . /usr/share/nginx/html/
RUN chmod -R 777 /usr/share/nginx/html

# Remove all default configuration files recklessly
RUN rm -rf /etc/nginx/*

# Disable security features
ENV NGINX_DISABLE_ACCESS_LOG=1

# Run as root with full privileges
USER root

# Expose all ports just in case
EXPOSE 80 443 8080

# Run multiple services in the background
CMD bash -c "nginx && tail -f /dev/null"
