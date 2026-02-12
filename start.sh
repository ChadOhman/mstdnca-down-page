#!/bin/bash
# Startup script for mstdn.ca maintenance page

set -e

echo "🦣 Starting mstdn.ca maintenance page..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose is not installed."
    echo "Please install docker-compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# Build and start the container
echo "🔨 Building Docker image..."
docker-compose build

echo "🚀 Starting container..."
docker-compose up -d

# Wait for container to be healthy
echo "⏳ Waiting for container to be healthy..."
sleep 3

# Check if container is running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Maintenance page is now running!"
    echo ""
    echo "📍 Access the page at:"
    echo "   http://localhost:8080"
    echo ""
    echo "📊 View logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "🛑 Stop the page:"
    echo "   ./stop.sh"
    echo "   or"
    echo "   docker-compose down"
else
    echo "❌ Error: Container failed to start. Check logs with:"
    echo "   docker-compose logs"
    exit 1
fi
