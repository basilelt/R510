FROM nginx:1.27

# Install curl for potential debugging
RUN apt-get update && apt-get install -y curl

# Copy custom nginx configuration
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy custom index.html
COPY index.html /usr/share/nginx/html/index.html

# Copy and make the update script executable
COPY update-html.sh /docker-entrypoint.d/update-html.sh
RUN chmod +x /docker-entrypoint.d/update-html.sh

# Use the default nginx command
CMD ["nginx", "-g", "daemon off;"]