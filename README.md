# mstdn.ca Maintenance Page

A fun, interactive maintenance page for the mstdn.ca Mastodon instance featuring 6 different mini-games that randomly display when users visit during downtime.

## Quick Start with Docker (Recommended)

The fastest way to run this maintenance page is with Docker:

```bash
# Linux/Mac
./start.sh

# Windows
start.bat

# Or manually
docker-compose up -d
```

Then visit **http://localhost:8080** to see the page.

See [DOCKER.md](DOCKER.md) for complete Docker deployment guide.

## Features

- **6 Mini-Games**: Snake, Pong, Breakout, Flappy Bird, Space Invaders, and Memory Match
- **Random Selection**: Different game on each page refresh
- **Mastodon-Themed**: Uses Mastodon's purple color scheme
- **Status Link**: Direct link to status.mstdn.ca for maintenance updates
- **Mobile-Responsive**: Works on desktop and mobile devices
- **Self-Contained**: Single HTML file with no external dependencies
- **Proper HTTP Status**: Returns 503 Service Unavailable with Retry-After headers
- **Fully Accessible**: WCAG 2.1 Level AA compliant with comprehensive screen reader support, keyboard navigation, and ARIA labels

## Games Included

1. **Snake** - Classic snake game. Use arrow keys to eat food and grow.
2. **Pong** - Two-player pong. Player 1 uses W/S, Player 2 uses arrow keys.
3. **Breakout** - Brick breaker. Use arrow keys to move the paddle.
4. **Flappy Bird** - Tap space or click to navigate through pipes.
5. **Space Invaders** - Defend against aliens. Arrow keys to move, space to shoot.
6. **Memory Match** - Click to flip cards and match all pairs.

## Installation Instructions

### Step 1: Prepare the Maintenance Directory

```bash
# Create the maintenance directory
sudo mkdir -p /var/www/maintenance

# Copy the index.html file to the maintenance directory
sudo cp index.html /var/www/maintenance/

# Set proper permissions
sudo chown -R www-data:www-data /var/www/maintenance
sudo chmod -R 755 /var/www/maintenance
```

### Step 2: Configure Nginx

You have two options for nginx configuration:

#### Option A: Replace Your Entire Nginx Configuration (Simple)

If you want to completely replace your Mastodon instance with the maintenance page:

```bash
# Backup your current nginx configuration
sudo cp /etc/nginx/sites-available/mstdn.ca /etc/nginx/sites-available/mstdn.ca.backup

# Copy the maintenance nginx configuration
sudo cp nginx.conf /etc/nginx/sites-available/mstdn.ca

# Test nginx configuration
sudo nginx -t

# If test passes, reload nginx
sudo systemctl reload nginx
```

#### Option B: Use Nginx Maintenance Mode (Advanced)

If you want to easily toggle maintenance mode on/off:

1. Create a maintenance flag file approach:

```bash
# Edit your existing nginx config
sudo nano /etc/nginx/sites-available/mstdn.ca
```

2. Add this at the top of your server block (before any location blocks):

```nginx
# Maintenance mode check
if (-f /var/www/maintenance/enable) {
    return 503;
}

# Error page configuration
error_page 503 @maintenance;

location @maintenance {
    root /var/www/maintenance;
    rewrite ^(.*)$ /index.html break;
    add_header Retry-After 3600 always;
    add_header Cache-Control "no-cache, no-store, must-revalidate" always;
    add_header Pragma "no-cache" always;
    add_header Expires "0" always;
}
```

3. Enable/disable maintenance mode:

```bash
# Enable maintenance mode
sudo touch /var/www/maintenance/enable
sudo systemctl reload nginx

# Disable maintenance mode (restore normal operation)
sudo rm /var/www/maintenance/enable
sudo systemctl reload nginx
```

### Step 3: Update SSL Certificates (if applicable)

If you're using HTTPS, make sure to update the SSL certificate paths in the nginx configuration:

```nginx
ssl_certificate /path/to/your/certificate.crt;
ssl_certificate_key /path/to/your/private.key;
```

Common certificate locations:
- Let's Encrypt: `/etc/letsencrypt/live/mstdn.ca/fullchain.pem` and `privkey.pem`
- Custom certificates: `/etc/ssl/certs/` and `/etc/ssl/private/`

### Step 4: Verify Configuration

```bash
# Test nginx configuration
sudo nginx -t

# Check if the page is accessible
curl -I http://localhost

# You should see HTTP 503 status
```

### Step 5: Monitor and Test

1. Visit your domain in a browser
2. You should see the maintenance page with a random game
3. Refresh the page to see different games
4. Verify the link to status.mstdn.ca works
5. Check that the HTTP status is 503 (you can use browser dev tools or curl)

```bash
# Check HTTP status
curl -I https://mstdn.ca
```

## Accessibility

This maintenance page is fully accessible and compliant with WCAG 2.1 Level AA standards:

- **Screen Reader Support**: Full ARIA labels, live regions for dynamic content, and automatic announcements
- **Keyboard Navigation**: All features accessible via keyboard with visible focus indicators
- **High Contrast**: Meets WCAG AA contrast ratio requirements
- **Semantic HTML**: Proper heading structure and landmark regions
- **Mobile Accessible**: Touch-friendly and responsive design

For detailed accessibility information, see [ACCESSIBILITY.md](ACCESSIBILITY.md).

## Customization

### Change the Retry-After Duration

Edit the `Retry-After` header in nginx.conf (value is in seconds):

```nginx
add_header Retry-After 3600 always;  # 1 hour
add_header Retry-After 7200 always;  # 2 hours
add_header Retry-After 1800 always;  # 30 minutes
```

### Modify the Maintenance Message

Edit the message in index.html:

```html
<p class="message">We're currently performing maintenance. Please check back soon!</p>
```

### Change the Status Link

Update the status link URL in index.html:

```html
<a href="https://status.mstdn.ca" class="status-link" target="_blank">Check Status Updates →</a>
```

## Troubleshooting

### Page Not Showing

1. Check nginx error logs: `sudo tail -f /var/log/nginx/error.log`
2. Verify file permissions: `ls -la /var/www/maintenance/`
3. Ensure nginx is running: `sudo systemctl status nginx`

### Wrong HTTP Status Code

- Make sure the `return 503;` directive is in the nginx configuration
- Verify with: `curl -I https://mstdn.ca` (should show "503 Service Unavailable")

### Games Not Working

- Check browser console for JavaScript errors (F12 in most browsers)
- Ensure the HTML file wasn't corrupted during transfer
- Try a different browser

### SSL/HTTPS Issues

1. Verify certificate paths are correct
2. Check certificate validity: `sudo openssl x509 -in /path/to/cert.crt -text -noout`
3. Ensure ports 80 and 443 are open in firewall

## Restoring Normal Operation

When maintenance is complete:

### If Using Option A (Complete Replacement):

```bash
# Restore your backup
sudo cp /etc/nginx/sites-available/mstdn.ca.backup /etc/nginx/sites-available/mstdn.ca

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### If Using Option B (Maintenance Flag):

```bash
# Simply remove the maintenance flag file
sudo rm /var/www/maintenance/enable
sudo systemctl reload nginx
```

## Testing Before Deployment

Before deploying to production, test locally:

1. Open index.html in your browser directly
2. Test all 6 games to ensure they work
3. Verify responsiveness on mobile devices
4. Check the link to status.mstdn.ca

## HTTP Response Codes Explained

This configuration uses **503 Service Unavailable** which is the correct status for temporary downtime:

- **503**: Indicates the server is temporarily unable to handle requests
- **Retry-After header**: Tells clients/bots when to check back
- **Cache-Control headers**: Prevents caching of the maintenance page

This is better than:
- **404**: Would indicate the page doesn't exist
- **500**: Would indicate a server error
- **200**: Would indicate everything is working normally

## License

Free to use and modify for your Mastodon instance.

## Credits

Built for mstdn.ca with love and mini-games! 🦣
