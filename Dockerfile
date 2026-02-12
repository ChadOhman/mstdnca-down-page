# Use official nginx alpine image for smaller size
FROM nginx:alpine

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx-docker.conf /etc/nginx/conf.d/maintenance.conf

# Copy the maintenance page
COPY index.html /usr/share/nginx/html/index.html

# Set proper permissions
RUN chmod -R 755 /usr/share/nginx/html && \
    chown -R nginx:nginx /usr/share/nginx/html

# Expose port 80 (and 443 if using SSL)
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Use nginx's default command
CMD ["nginx", "-g", "daemon off;"]
