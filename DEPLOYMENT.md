# Deployment Guide

This document provides generic deployment instructions without sensitive information.

## Requirements

- Nginx web server
- PHP 8.1+ with PHP-FPM
- Write permissions for scores.json

## Quick Deployment

1. **Upload Files**
   ```bash
   # Upload to your web server
   scp index.html scores.php scores.json user@your-server:/var/www/maintenance/
   ```

2. **Set Permissions**
   ```bash
   chown www-data:www-data /var/www/maintenance/*
   chmod 664 /var/www/maintenance/scores.json
   ```

3. **Configure Nginx**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       root /var/www/maintenance;
       index index.html;

       # PHP processing
       location ~ \.php$ {
           try_files $uri =404;
           fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
           fastcgi_index index.php;
           fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
           include fastcgi_params;
       }

       # Serve with 503 status
       location / {
           try_files $uri /index.html =503;
           add_header Cache-Control "no-cache, no-store, must-revalidate" always;
           return 503;
       }

       error_page 503 /index.html;
   }
   ```

4. **Install PHP** (if needed)
   ```bash
   apt-get update
   apt-get install -y php-fpm php-json
   systemctl enable php8.1-fpm
   systemctl start php8.1-fpm
   ```

5. **Test**
   - Visit http://your-domain.com
   - Play a game and submit a score
   - Verify scores persist after refresh

## Features

- 7 mini-games (Snake, Pong, Breakout, Tetris, Space Invaders, Asteroids, Memory Match)
- High score system (no database required)
- Mobile responsive with touch controls
- WCAG 2.1 Level AA accessibility compliant
- Displays 503 Service Unavailable status

## Configuration

### Changing the Status Link
Edit `index.html` line ~251:
```html
<a href="https://status.your-domain.com" ...>
```

### Adjusting High Score Limits
Edit `scores.php` line ~73 to change max scores per game (default: 100)

## Troubleshooting

### PHP Not Working
```bash
# Check PHP-FPM status
systemctl status php8.1-fpm

# Check PHP errors
tail -f /var/log/nginx/error.log

# Test PHP directly
php /var/www/maintenance/scores.php
```

### Scores Not Saving
```bash
# Check file permissions
ls -la /var/www/maintenance/scores.json

# Should be: -rw-rw-r-- www-data www-data

# Fix permissions
chown www-data:www-data scores.json
chmod 664 scores.json
```

### 404 Errors
Verify nginx is serving from correct directory and index.html exists.
