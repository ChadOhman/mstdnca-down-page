#!/bin/bash
# Copy this ENTIRE script into the DigitalOcean console

# Install nginx
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq && apt-get install -y -qq nginx ufw

# Create directory
mkdir -p /var/www/maintenance

# Create maintenance page (minimal version - will upgrade after)
cat > /var/www/maintenance/index.html <<'HTMLEOF'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>mstdn.ca - Maintenance</title><style>body{font-family:system-ui;background:linear-gradient(135deg,#6364FF,#563acc);color:#fff;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;padding:20px;text-align:center}.container{max-width:600px}h1{font-size:2.5rem;margin-bottom:1rem}p{font-size:1.2rem;opacity:0.9;margin-bottom:2rem}a{display:inline-block;background:rgba(255,255,255,0.2);padding:12px 24px;border-radius:8px;color:#fff;text-decoration:none;font-weight:600}a:hover{background:rgba(255,255,255,0.3)}.game{background:rgba(255,255,255,0.1);border-radius:12px;padding:20px;margin-top:2rem}canvas{background:#2b2d42;border-radius:8px;max-width:100%}</style></head><body><div class="container"><div style="font-size:3rem;margin-bottom:1rem">🦣</div><h1>mstdn.ca is temporarily down</h1><p>We're currently performing maintenance. Please check back soon!</p><a href="https://status.mstdn.ca" target="_blank">Check Status Updates →</a><div class="game"><h2>Snake Game</h2><p>Use arrow keys to play</p><canvas id="c" width="400" height="400"></canvas><div id="score" style="margin-top:1rem;font-size:1.2rem">Score: 0</div></div></div><script>const c=document.getElementById('c'),ctx=c.getContext('2d'),s=20,t=20;let snake=[{x:10,y:10}],dx=1,dy=0,food={x:15,y:15},score=0,over=false;document.addEventListener('keydown',e=>{if(e.key==='ArrowUp'&&dy===0){dx=0;dy=-1}else if(e.key==='ArrowDown'&&dy===0){dx=0;dy=1}else if(e.key==='ArrowLeft'&&dx===0){dx=-1;dy=0}else if(e.key==='ArrowRight'&&dx===0){dx=1;dy=0}});function draw(){if(over)return;const head={x:snake[0].x+dx,y:snake[0].y+dy};if(head.x<0||head.x>=t||head.y<0||head.y>=t||snake.some(seg=>seg.x===head.x&&seg.y===head.y)){over=true;ctx.fillStyle='rgba(0,0,0,0.7)';ctx.fillRect(0,0,400,400);ctx.fillStyle='#fff';ctx.font='32px Arial';ctx.textAlign='center';ctx.fillText('Game Over!',200,200);return}snake.unshift(head);if(head.x===food.x&&head.y===food.y){score+=10;food={x:Math.floor(Math.random()*t),y:Math.floor(Math.random()*t)}}else{snake.pop()}ctx.fillStyle='#2b2d42';ctx.fillRect(0,0,400,400);ctx.fillStyle='#6364FF';snake.forEach(seg=>ctx.fillRect(seg.x*s,seg.y*s,s-2,s-2));ctx.fillStyle='#ff006e';ctx.fillRect(food.x*s,food.y*s,s-2,s-2);document.getElementById('score').textContent='Score: '+score}setInterval(draw,100)</script></body></html>
HTMLEOF

# Configure nginx
cat > /etc/nginx/sites-available/maintenance <<'NGINXEOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /var/www/maintenance;
    index index.html;
    location / {
        try_files /index.html =503;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
        return 503;
    }
    error_page 503 /index.html;
}
NGINXEOF

# Enable site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/maintenance /etc/nginx/sites-enabled/
nginx -t

# Firewall
ufw --force enable
ufw allow ssh
ufw allow http

# Permissions
chown -R www-data:www-data /var/www/maintenance
chmod -R 755 /var/www/maintenance

# Start nginx
systemctl enable nginx
systemctl restart nginx

echo ""
echo "✅ DONE! Visit http://178.128.238.46"
echo ""
