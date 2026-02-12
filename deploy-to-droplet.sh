#!/bin/bash
# Automated deployment script for mstdn.ca maintenance page
# Optimized for 512MB droplet (using nginx directly, not Docker)

set -e

echo "🦣 Deploying mstdn.ca maintenance page..."
echo "Target: 178.128.238.46"
echo ""

# Update system
echo "📦 Updating system packages..."
apt-get update -qq
apt-get upgrade -y -qq

# Install nginx and certbot (even though we won't use certbot with Cloudflare)
echo "📦 Installing nginx..."
apt-get install -y -qq nginx ufw curl wget

# Create maintenance directory
echo "📁 Creating directories..."
mkdir -p /var/www/maintenance
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

# Download or create index.html
echo "📝 Creating maintenance page..."
cat > /var/www/maintenance/index.html <<'HTMLEOF'
HTMLEOF

# Create nginx configuration for HTTP only (Cloudflare handles HTTPS)
echo "⚙️  Configuring nginx..."
cat > /etc/nginx/sites-available/maintenance <<'NGINXEOF'
# Nginx configuration for maintenance page (behind Cloudflare)
# Cloudflare handles SSL, so we only serve HTTP

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/maintenance;
    index index.html;

    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/html application/javascript application/json;

    # Serve maintenance page with 503 status
    location / {
        try_files /index.html =503;
        add_header Retry-After 3600 always;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
        add_header Pragma "no-cache" always;
        add_header Expires "0" always;
        return 503;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Error page
    location = /index.html {
        internal;
        add_header Retry-After 3600 always;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
    }

    error_page 503 /index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Cloudflare real IP
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 104.24.0.0/14;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 131.0.72.0/22;
    set_real_ip_from 2400:cb00::/32;
    set_real_ip_from 2606:4700::/32;
    set_real_ip_from 2803:f800::/32;
    set_real_ip_from 2405:b500::/32;
    set_real_ip_from 2405:8100::/32;
    set_real_ip_from 2a06:98c0::/29;
    set_real_ip_from 2c0f:f248::/32;
    real_ip_header CF-Connecting-IP;
}
NGINXEOF

# Remove default nginx site
rm -f /etc/nginx/sites-enabled/default

# Enable maintenance site
ln -sf /etc/nginx/sites-available/maintenance /etc/nginx/sites-enabled/

# Test nginx configuration
echo "🔍 Testing nginx configuration..."
nginx -t

# Configure firewall
echo "🔒 Configuring firewall..."
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https

# Set proper permissions
echo "🔐 Setting permissions..."
chown -R www-data:www-data /var/www/maintenance
chmod -R 755 /var/www/maintenance

# Reload nginx
echo "🔄 Reloading nginx..."
systemctl enable nginx
systemctl restart nginx

# Show status
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Status:"
systemctl status nginx --no-pager -l | head -n 10
echo ""
echo "🌐 Server IP: 178.128.238.46"
echo "🔗 Test: http://178.128.238.46"
echo ""
echo "📋 Next steps:"
echo "  1. Point mstdn.ca DNS A record to: 178.128.238.46"
echo "  2. Configure Cloudflare:"
echo "     - SSL/TLS mode: Full (not Full Strict)"
echo "     - Proxy status: Proxied (orange cloud)"
echo "  3. Test: https://mstdn.ca"
echo ""
echo "🎮 The page will show a random mini-game on each refresh!"
