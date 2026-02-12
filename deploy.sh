#!/bin/bash
# Local deployment script - run this from your machine
# This will deploy the maintenance page to the DigitalOcean droplet

DROPLET_IP="178.128.238.46"
SSH_KEY="./droplet_key"

echo "🦣 Deploying mstdn.ca maintenance page to droplet..."
echo "Target: $DROPLET_IP"
echo ""

# Check if index.html exists
if [ ! -f "index.html" ]; then
    echo "❌ Error: index.html not found"
    exit 1
fi

echo "📤 Copying maintenance page to droplet..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    index.html root@$DROPLET_IP:/tmp/

echo "🔧 Installing and configuring nginx..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    root@$DROPLET_IP 'bash -s' <<'ENDSSH'

set -e

# Update system
echo "📦 Updating system..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq

# Install nginx
echo "📦 Installing nginx..."
apt-get install -y -qq nginx ufw

# Create maintenance directory
mkdir -p /var/www/maintenance

# Move index.html
mv /tmp/index.html /var/www/maintenance/

# Create nginx config
cat > /etc/nginx/sites-available/maintenance <<'NGINXEOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/maintenance;
    index index.html;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/html application/javascript;

    location / {
        try_files /index.html =503;
        add_header Retry-After 3600 always;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
        add_header Pragma "no-cache" always;
        add_header Expires "0" always;
        return 503;
    }

    location = /index.html {
        internal;
    }

    error_page 503 /index.html;
}
NGINXEOF

# Enable site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/maintenance /etc/nginx/sites-enabled/

# Test config
nginx -t

# Configure firewall
ufw --force enable
ufw allow ssh
ufw allow http

# Set permissions
chown -R www-data:www-data /var/www/maintenance
chmod -R 755 /var/www/maintenance

# Restart nginx
systemctl enable nginx
systemctl restart nginx

echo "✅ Deployment complete!"

ENDSSH

echo ""
echo "✅ Deployment successful!"
echo ""
echo "🌐 Your maintenance page is now live at:"
echo "   http://$DROPLET_IP"
echo ""
echo "📋 Next steps:"
echo "  1. Test it: http://$DROPLET_IP"
echo "  2. Point mstdn.ca A record to: $DROPLET_IP"
echo "  3. Configure Cloudflare to proxy the traffic"
echo ""
