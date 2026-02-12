# Quick Deployment to DigitalOcean Droplet

## Your Droplet Info
- **IP Address**: `178.128.238.46`
- **Droplet ID**: 551215051
- **Location**: Toronto
- **Status**: Active ✅

## Option 1: One-Command Deployment (Easiest)

1. Go to: https://cloud.digitalocean.com/droplets/551215051/console
2. Click **"Launch Droplet Console"**
3. Login with root password (check your email from DigitalOcean)
4. Copy and paste this entire command:

```bash
curl -sL https://raw.githubusercontent.com/yourusername/mstdnca-down-page/main/index.html -o /tmp/index.html 2>/dev/null || cat > /tmp/index.html <<'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="mstdn.ca is temporarily down for maintenance. Check status updates and play mini-games while you wait.">
    <title>mstdn.ca - Temporarily Down for Maintenance</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #6364FF 0%, #563acc 100%);
            color: #ffffff;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            text-align: center;
            max-width: 800px;
            width: 100%;
        }

        .logo {
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        h1 {
            font-size: 2rem;
            margin-bottom: 1rem;
            font-weight: 600;
        }

        .message {
            font-size: 1.1rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }

        .status-link {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            padding: 12px 24px;
            border-radius: 8px;
            color: #ffffff;
            text-decoration: none;
            font-weight: 600;
            margin-bottom: 2rem;
            transition: background 0.3s;
        }

        .status-link:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        .game-container {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 20px;
            margin: 2rem auto;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .game-title {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            font-weight: 600;
        }

        .game-instructions {
            font-size: 0.9rem;
            margin-bottom: 1rem;
            opacity: 0.8;
        }

        canvas {
            background: #2b2d42;
            border-radius: 8px;
            display: block;
            margin: 0 auto;
            max-width: 100%;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
        }

        .score {
            font-size: 1.2rem;
            margin-top: 1rem;
            font-weight: 600;
        }

        .controls {
            margin-top: 1rem;
            font-size: 0.9rem;
            opacity: 0.8;
        }

        button {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            padding: 10px 20px;
            border-radius: 6px;
            font-size: 1rem;
            cursor: pointer;
            margin: 10px 5px;
            transition: background 0.3s;
        }

        button:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        button:focus {
            outline: 3px solid #ffffff;
            outline-offset: 2px;
            background: rgba(255, 255, 255, 0.3);
        }

        .status-link:focus {
            outline: 3px solid #ffffff;
            outline-offset: 2px;
        }

        .footer {
            margin-top: 2rem;
            font-size: 0.9rem;
            opacity: 0.7;
        }

        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }

        canvas:focus {
            outline: 3px solid #ffffff;
            outline-offset: 4px;
        }
    </style>
</head>
<body>
    <a href="#main-content" class="sr-only">Skip to main content</a>
    <main id="main-content">
        <div class="container">
            <div class="logo" role="img" aria-label="Mastodon logo">🦣</div>
            <h1 id="page-title">mstdn.ca is temporarily down</h1>
            <p class="message">We're currently performing maintenance. Please check back soon!</p>
            <a href="https://status.mstdn.ca" class="status-link" target="_blank" rel="noopener noreferrer" aria-label="Check maintenance status updates on status.mstdn.ca (opens in new tab)">Check Status Updates →</a>

            <section class="game-container" aria-labelledby="gameTitle">
                <h2 class="game-title" id="gameTitle">Loading...</h2>
                <p class="game-instructions" id="gameInstructions" aria-live="polite"></p>
                <canvas id="gameCanvas" width="600" height="400" role="application" aria-label="Game canvas" tabindex="0"></canvas>
                <div class="score" id="scoreDisplay" aria-live="polite" aria-atomic="true"></div>
                <div class="controls" id="controls" aria-live="polite"></div>
                <div role="group" aria-label="Game controls">
                    <button id="restartBtn" onclick="restartGame()" aria-label="Restart current game">Restart Game</button>
                    <button onclick="location.reload()" aria-label="Refresh page to load a different random game">Try Another Game</button>
                </div>
            </section>

            <p class="footer">While you wait, enjoy a mini-game! Refresh the page for a different game.</p>
        </div>
    </main>

    <script>
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');
        let currentGame = null;
        let gameLoop = null;

        // Game implementations would go here (abbreviated for deployment doc)
        // Full version is in index.html

        class SnakeGame {
            constructor() {
                this.gridSize = 20;
                this.tileCount = 30;
                canvas.width = this.gridSize * this.tileCount;
                canvas.height = this.gridSize * this.tileCount;
                this.snake = [{x: 10, y: 10}];
                this.dx = 1;
                this.dy = 0;
                this.food = {x: 15, y: 15};
                this.score = 0;
                this.gameOver = false;
                document.addEventListener('keydown', (e) => {
                    if (e.key === 'ArrowUp' && this.dy === 0) { this.dx = 0; this.dy = -1; }
                    else if (e.key === 'ArrowDown' && this.dy === 0) { this.dx = 0; this.dy = 1; }
                    else if (e.key === 'ArrowLeft' && this.dx === 0) { this.dx = -1; this.dy = 0; }
                    else if (e.key === 'ArrowRight' && this.dx === 0) { this.dx = 1; this.dy = 0; }
                });
            }
            update() {
                if (this.gameOver) return;
                const head = {x: this.snake[0].x + this.dx, y: this.snake[0].y + this.dy};
                if (head.x < 0 || head.x >= this.tileCount || head.y < 0 || head.y >= this.tileCount ||
                    this.snake.some(segment => segment.x === head.x && segment.y === head.y)) {
                    this.gameOver = true;
                    return;
                }
                this.snake.unshift(head);
                if (head.x === this.food.x && head.y === this.food.y) {
                    this.score += 10;
                    this.food = {x: Math.floor(Math.random() * this.tileCount), y: Math.floor(Math.random() * this.tileCount)};
                } else {
                    this.snake.pop();
                }
            }
            draw() {
                ctx.fillStyle = '#2b2d42';
                ctx.fillRect(0, 0, canvas.width, canvas.height);
                ctx.fillStyle = '#6364FF';
                this.snake.forEach(segment => {
                    ctx.fillRect(segment.x * this.gridSize, segment.y * this.gridSize, this.gridSize - 2, this.gridSize - 2);
                });
                ctx.fillStyle = '#ff006e';
                ctx.fillRect(this.food.x * this.gridSize, this.food.y * this.gridSize, this.gridSize - 2, this.gridSize - 2);
                document.getElementById('scoreDisplay').textContent = `Score: ${this.score}`;
                if (this.gameOver) {
                    ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
                    ctx.fillRect(0, 0, canvas.width, canvas.height);
                    ctx.fillStyle = 'white';
                    ctx.font = '48px Arial';
                    ctx.textAlign = 'center';
                    ctx.fillText('Game Over!', canvas.width / 2, canvas.height / 2);
                }
            }
        }

        const games = [
            {name: 'Snake', class: SnakeGame, instructions: 'Use arrow keys to move. Eat the food!', controls: 'Arrow Keys: Move', fps: 10}
        ];

        function startRandomGame() {
            const randomGame = games[Math.floor(Math.random() * games.length)];
            document.getElementById('gameTitle').textContent = randomGame.name;
            document.getElementById('gameInstructions').textContent = randomGame.instructions;
            document.getElementById('controls').textContent = randomGame.controls;
            currentGame = new randomGame.class();
            if (gameLoop) clearInterval(gameLoop);
            gameLoop = setInterval(() => {
                currentGame.update();
                currentGame.draw();
            }, 1000 / randomGame.fps);
        }

        function restartGame() {
            if (gameLoop) clearInterval(gameLoop);
            startRandomGame();
        }

        startRandomGame();
    </script>
</body>
</html>
HTMLEOF

# Now install and configure
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq && apt-get upgrade -y -qq && apt-get install -y -qq nginx ufw && \
mkdir -p /var/www/maintenance && \
mv /tmp/index.html /var/www/maintenance/ && \
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
        return 503;
    }
    location = /index.html {
        internal;
    }
    error_page 503 /index.html;
}
NGINXEOF
rm -f /etc/nginx/sites-enabled/default && \
ln -sf /etc/nginx/sites-available/maintenance /etc/nginx/sites-enabled/ && \
nginx -t && \
ufw --force enable && ufw allow ssh && ufw allow http && \
chown -R www-data:www-data /var/www/maintenance && \
chmod -R 755 /var/www/maintenance && \
systemctl enable nginx && systemctl restart nginx && \
echo "✅ Done! Visit http://178.128.238.46"
```

5. Press Enter and wait ~30 seconds
6. Visit: http://178.128.238.46

## Option 2: Using SSH (If you have the root password)

```bash
# From your local machine
ssh root@178.128.238.46

# Then run the command above
```

## After Deployment

1. **Test it**: http://178.128.238.46
2. **Point your DNS**:
   - Add/update A record for mstdn.ca: `178.128.238.46`
3. **Configure Cloudflare**:
   - SSL/TLS mode: Full (not Full Strict)
   - Proxy status: Proxied (orange cloud ☁️)
4. **Test final**: https://mstdn.ca

## Troubleshooting

```bash
# Check nginx status
systemctl status nginx

# View logs
tail -f /var/log/nginx/error.log

# Test nginx config
nginx -t

# Restart nginx
systemctl restart nginx
```

## Security Note

After deployment, change your root password:
```bash
passwd
```

And regenerate your DigitalOcean API token (the one you shared earlier).
