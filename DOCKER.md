# Docker Deployment Guide

This guide explains how to deploy the maintenance page using Docker and Docker Compose.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- [Docker Compose](https://docs.docker.com/compose/install/) installed (usually comes with Docker Desktop)

## Quick Start (Turnkey Solution)

### 1. Build and Start the Container

```bash
# From the project directory
docker-compose up -d
```

That's it! The maintenance page will be available at:
- **http://localhost:8080**

### 2. Verify It's Running

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Check health
docker-compose exec maintenance wget -qO- http://localhost/health
```

### 3. Stop the Container

```bash
docker-compose down
```

## Detailed Usage

### Building the Image

Build the Docker image manually:

```bash
docker build -t mstdnca-maintenance:latest .
```

### Running with Docker Compose

```bash
# Start in detached mode (background)
docker-compose up -d

# Start with logs visible
docker-compose up

# Rebuild and start (after making changes)
docker-compose up -d --build

# Stop the services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Running with Docker (without Compose)

```bash
# Build the image
docker build -t mstdnca-maintenance:latest .

# Run the container
docker run -d \
  --name mstdn-maintenance \
  -p 8080:80 \
  --restart unless-stopped \
  mstdnca-maintenance:latest

# Stop the container
docker stop mstdn-maintenance

# Remove the container
docker rm mstdn-maintenance
```

## Configuration

### Changing the Port

Edit `docker-compose.yml` and change the port mapping:

```yaml
ports:
  - "80:80"  # Host port 80 -> Container port 80
  # or
  - "3000:80"  # Host port 3000 -> Container port 80
```

### Custom Domain/Host

The Docker setup uses a wildcard server name (`server_name _;`) so it responds to any hostname. To test with a specific domain:

1. Add an entry to your `/etc/hosts` (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
   ```
   127.0.0.1 mstdn.local
   ```

2. Access via http://mstdn.local:8080

### Environment Variables

Customize the timezone in `docker-compose.yml`:

```yaml
environment:
  - TZ=America/Toronto  # Change to your timezone
```

### SSL/HTTPS Support

To enable HTTPS, you'll need to:

1. **Create an SSL-enabled Nginx config**:

Create `nginx-docker-ssl.conf`:
```nginx
server {
    listen 80;
    listen [::]:80;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name _;

    ssl_certificate /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    root /usr/share/nginx/html;

    location / {
        try_files /index.html =503;
        add_header Retry-After 3600 always;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
        return 503;
    }

    location = /index.html {
        internal;
        add_header Retry-After 3600 always;
    }

    error_page 503 /index.html;
}
```

2. **Update docker-compose.yml**:
```yaml
services:
  maintenance:
    # ... existing config ...
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./certs:/etc/nginx/certs:ro
```

3. **Place your SSL certificates** in a `certs/` directory:
   - `fullchain.pem`
   - `privkey.pem`

## Health Checks

The container includes a health check endpoint:

```bash
# Check if container is healthy
docker inspect mstdn-maintenance --format='{{.State.Health.Status}}'

# View health check logs
docker inspect mstdn-maintenance --format='{{json .State.Health}}' | jq
```

The health endpoint is available at:
- **http://localhost:8080/health**

## Production Deployment

### Option 1: Direct Replacement

Replace your existing service with this container:

```bash
# Stop your Mastodon instance
systemctl stop mastodon-web

# Start maintenance container on port 80
docker-compose up -d
```

### Option 2: Reverse Proxy

If using nginx or another reverse proxy, point it to the Docker container:

```nginx
upstream maintenance {
    server localhost:8080;
}

server {
    listen 80;
    server_name mstdn.ca;

    location / {
        proxy_pass http://maintenance;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Option 3: Docker Swarm/Kubernetes

For orchestrated environments, see the respective deployment guides.

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs maintenance

# Check if port is in use
netstat -an | grep 8080  # Linux/Mac
netstat -ano | findstr 8080  # Windows
```

### Permission errors

```bash
# Rebuild with no cache
docker-compose build --no-cache

# Check file permissions
ls -la
```

### Container is running but page won't load

```bash
# Test directly on the container
docker-compose exec maintenance wget -qO- http://localhost/

# Check nginx configuration
docker-compose exec maintenance nginx -t

# View nginx error log
docker-compose exec maintenance cat /var/log/nginx/error.log
```

### Changes not appearing

```bash
# Rebuild the image
docker-compose up -d --build --force-recreate
```

## Monitoring

### View Logs

```bash
# Follow logs (Ctrl+C to exit)
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# Logs for specific service
docker-compose logs maintenance
```

### Container Stats

```bash
# Real-time stats
docker stats mstdn-maintenance

# One-time stats
docker stats --no-stream mstdn-maintenance
```

### Inspect Container

```bash
# Full container details
docker inspect mstdn-maintenance

# Specific details
docker inspect mstdn-maintenance --format='{{.State.Status}}'
docker inspect mstdn-maintenance --format='{{.NetworkSettings.IPAddress}}'
```

## Updating the Page

1. **Edit** `index.html`
2. **Rebuild** the container:
   ```bash
   docker-compose up -d --build
   ```

## Resource Limits

Add resource constraints in `docker-compose.yml`:

```yaml
services:
  maintenance:
    # ... existing config ...
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
        reservations:
          cpus: '0.25'
          memory: 64M
```

## Backup and Export

### Save the Image

```bash
# Save image to tar file
docker save mstdnca-maintenance:latest -o maintenance.tar

# Load image on another machine
docker load -i maintenance.tar
```

### Export Container State

```bash
# Create a new image from running container
docker commit mstdn-maintenance mstdnca-maintenance:backup
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Build and Push Maintenance Page

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Docker image
        run: docker build -t mstdnca-maintenance:latest .

      - name: Test container
        run: |
          docker run -d -p 8080:80 --name test mstdnca-maintenance:latest
          sleep 5
          curl -f http://localhost:8080/ || exit 1
          docker stop test
```

## Security Best Practices

1. **Keep base image updated**:
   ```bash
   docker pull nginx:alpine
   docker-compose build --pull
   ```

2. **Scan for vulnerabilities**:
   ```bash
   docker scan mstdnca-maintenance:latest
   ```

3. **Run as non-root** (already configured in Dockerfile)

4. **Use read-only root filesystem** (add to docker-compose.yml):
   ```yaml
   read_only: true
   tmpfs:
     - /var/cache/nginx
     - /var/run
   ```

## Performance Tuning

### Nginx Worker Processes

The default nginx configuration auto-tunes worker processes. For manual tuning, create a custom `nginx.conf`.

### Enable HTTP/2

Already enabled in the SSL configuration.

### Caching

The maintenance page explicitly disables caching (as intended for maintenance mode).

## Multi-Architecture Support

Build for multiple architectures:

```bash
# Install buildx
docker buildx create --use

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t mstdnca-maintenance:latest .
```

## Alternative: Docker Hub

Push to Docker Hub for easy deployment:

```bash
# Tag the image
docker tag mstdnca-maintenance:latest yourusername/mstdnca-maintenance:latest

# Push to Docker Hub
docker push yourusername/mstdnca-maintenance:latest

# Pull and run on any server
docker run -d -p 80:80 yourusername/mstdnca-maintenance:latest
```

## Cleanup

Remove all related containers and images:

```bash
# Stop and remove containers
docker-compose down

# Remove images
docker rmi mstdnca-maintenance:latest

# Remove dangling images
docker image prune -f

# Remove all unused data
docker system prune -a
```

## Need Help?

- Check [Docker documentation](https://docs.docker.com/)
- View container logs: `docker-compose logs -f`
- Inspect configuration: `docker-compose config`

## Summary Commands

```bash
# Start: docker-compose up -d
# Stop: docker-compose down
# Logs: docker-compose logs -f
# Rebuild: docker-compose up -d --build
# Health: docker-compose exec maintenance wget -qO- http://localhost/health
```
