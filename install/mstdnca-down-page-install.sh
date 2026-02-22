#!/usr/bin/env bash
# mstdn.ca Maintenance Page - LXC Container Install Script
# This script runs INSIDE the container (pushed and executed by ct/mstdnca-down-page.sh)

set -euo pipefail

YW="\033[33m"
GN="\033[1;92m"
RD="\033[01;31m"
CL="\033[m"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

msg_info()  { echo -e "${YW}  [INFO]${CL} $1"; }
msg_ok()    { echo -e "  ${CM} $1"; }
msg_error() { echo -e "  ${CROSS} $1"; exit 1; }

PHP_VER="8.2"
WEB_ROOT="/var/www/maintenance"

# Update and install packages
msg_info "Updating system packages..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
msg_ok "System updated."

msg_info "Installing nginx and PHP ${PHP_VER}-FPM..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    nginx \
    php${PHP_VER}-fpm \
    php${PHP_VER}-cli \
    curl
msg_ok "nginx and PHP ${PHP_VER} installed."

# Web root
msg_info "Setting up web root..."
mkdir -p "$WEB_ROOT"

# scores.json must be writable by www-data
if [[ ! -f "${WEB_ROOT}/scores.json" ]]; then
    echo '{}' > "${WEB_ROOT}/scores.json"
fi

chown -R www-data:www-data "$WEB_ROOT"
chmod 755 "$WEB_ROOT"
chmod 644 "${WEB_ROOT}/index.html" 2>/dev/null || true
chmod 644 "${WEB_ROOT}/scores.php" 2>/dev/null || true
chmod 664 "${WEB_ROOT}/scores.json"
msg_ok "Web root configured at ${WEB_ROOT}."

# Configure nginx
msg_info "Configuring nginx..."

cat > /etc/nginx/sites-available/mstdn-down-page << 'NGINX_EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/maintenance;
    index index.html;

    # High scores API — must come before the catch-all location
    location = /scores.php {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type" always;
    }

    # Health check (for reverse proxy / uptime monitors)
    location = /health {
        return 200 'OK';
        add_header Content-Type text/plain;
        access_log off;
    }

    # All other requests → 503 maintenance page
    location / {
        try_files /index.html =503;
        add_header Retry-After 3600 always;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
        add_header Pragma "no-cache" always;
        add_header Expires "0" always;
        return 503;
    }

    error_page 503 /index.html;

    location = /index.html {
        internal;
        add_header Retry-After 3600 always;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
    }
}
NGINX_EOF

# Enable site, remove default
ln -sf /etc/nginx/sites-available/mstdn-down-page /etc/nginx/sites-enabled/mstdn-down-page
rm -f /etc/nginx/sites-enabled/default

nginx -t
msg_ok "nginx configured."

# Start services
msg_info "Enabling and starting services..."
systemctl enable php${PHP_VER}-fpm --quiet
systemctl start  php${PHP_VER}-fpm
systemctl enable nginx --quiet
systemctl start  nginx
msg_ok "Services started."

# Final check
echo ""
if systemctl is-active --quiet nginx && systemctl is-active --quiet php${PHP_VER}-fpm; then
    echo -e "${GN}  Installation complete.${CL}"
    echo -e "  Web root : ${WEB_ROOT}"
    echo -e "  nginx    : $(systemctl is-active nginx)"
    echo -e "  php-fpm  : $(systemctl is-active php${PHP_VER}-fpm)"
else
    msg_error "A service failed to start. Run 'systemctl status nginx' or 'systemctl status php${PHP_VER}-fpm' inside the CT for details."
fi
