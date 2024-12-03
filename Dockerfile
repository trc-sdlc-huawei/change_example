# Use the official Nginx image as the base image
FROM nginx:alpine

# Remove the default Nginx configuration file
RUN rm /usr/share/nginx/html/*

# Copy the static files to the Nginx web server directory
COPY . /usr/share/nginx/html/

COPY version.html /usr/share/version.html

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
