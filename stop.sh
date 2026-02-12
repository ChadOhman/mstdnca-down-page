#!/bin/bash
# Shutdown script for mstdn.ca maintenance page

set -e

echo "🛑 Stopping mstdn.ca maintenance page..."

if ! docker-compose ps | grep -q "Up"; then
    echo "ℹ️  Container is not running."
    exit 0
fi

docker-compose down

echo "✅ Maintenance page has been stopped."
echo ""
echo "💡 To start again, run:"
echo "   ./start.sh"
