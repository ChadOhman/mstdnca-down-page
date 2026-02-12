# Quick Start Guide

## Test the Page Locally (Right Now!)

The maintenance page should have just opened in your browser. If not:

1. Navigate to: `c:\Users\ChadOhman\Documents\GitHub\mstdnca-down-page\`
2. Double-click `index.html`

### What You Should See

- Mastodon purple gradient background
- A random mini-game (one of: Snake, Pong, Breakout, Flappy Bird, Space Invaders, or Memory Match)
- A link to "Check Status Updates" pointing to status.mstdn.ca
- Restart Game and Try Another Game buttons

### Quick Testing Steps

1. **Play the current game** - Use the controls shown
2. **Click "Try Another Game"** - Page should refresh with a different game
3. **Test all games** - Refresh until you've tried all 6 games
4. **Click the status link** - Should open status.mstdn.ca
5. **Check mobile** - Open on your phone to test responsiveness

## Deploy to Your Server

### Minimal Steps (5 Minutes)

```bash
# 1. Copy the file to your server
scp index.html your-server:/var/www/maintenance/

# 2. Copy and configure nginx
scp nginx.conf your-server:/etc/nginx/sites-available/mstdn.ca.maintenance

# 3. SSH into your server
ssh your-server

# 4. Backup current nginx config
sudo cp /etc/nginx/sites-available/mstdn.ca /etc/nginx/sites-available/mstdn.ca.backup

# 5. Activate maintenance config
sudo cp /etc/nginx/sites-available/mstdn.ca.maintenance /etc/nginx/sites-available/mstdn.ca

# 6. Update SSL certificate paths in the config (if needed)
sudo nano /etc/nginx/sites-available/mstdn.ca
# Update these lines:
#   ssl_certificate /path/to/your/cert.crt;
#   ssl_certificate_key /path/to/your/key.key;

# 7. Test nginx config
sudo nginx -t

# 8. Reload nginx
sudo systemctl reload nginx

# 9. Test!
curl -I https://mstdn.ca
# Should show: HTTP/1.1 503 Service Unavailable
```

### Restore Normal Operation

```bash
# Restore your backup
sudo cp /etc/nginx/sites-available/mstdn.ca.backup /etc/nginx/sites-available/mstdn.ca

# Reload nginx
sudo nginx -t
sudo systemctl reload nginx
```

## Alternative: Maintenance Mode Toggle

See [README.md](README.md) Option B for a setup that lets you toggle maintenance mode on/off with a single command.

## Troubleshooting

### Page doesn't load
- Check file location: `ls -la /var/www/maintenance/`
- Check nginx logs: `sudo tail -f /var/log/nginx/error.log`

### Wrong HTTP code
- Verify nginx config has `return 503;`
- Test: `curl -I https://mstdn.ca | grep 503`

### SSL errors
- Check certificate paths in nginx config
- Verify certs exist: `ls -la /etc/letsencrypt/live/mstdn.ca/`

## Files Included

- **index.html** - The maintenance page (this is all you need!)
- **nginx.conf** - Nginx configuration example
- **README.md** - Complete documentation
- **TESTING.md** - Testing checklist
- **QUICKSTART.md** - This file
- **validate.html** - Validation tool (optional)

## Need Help?

Check the full [README.md](README.md) for detailed instructions and troubleshooting.
