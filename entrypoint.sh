#!/bin/sh
# RADICAL SEA BUNNY - Docker Entrypoint

set -e

echo "🐇 RADICAL SEA BUNNY v2.0.0 - Container Starting"
echo "🌊 Initializing environment..."

# Check if running as root
if [ "$(id -u)" = "0" ]; then
    echo "⚠️ Running as root - this is required for network operations"
fi

# Create required directories
mkdir -p /app/.radical_sea_bunny
mkdir -p /app/radical_sea_bunny_reports
mkdir -p /app/.radical_sea_bunny/payloads
mkdir -p /app/.radical_sea_bunny/workspaces

# Set environment variables
export PYTHONPATH=/app:$PYTHONPATH

# Install any additional dependencies if needed
if [ -f "/app/requirements.txt" ]; then
    echo "📦 Checking dependencies..."
    pip install --no-cache-dir -r /app/requirements.txt || true
fi

# Create default config if not exists
if [ ! -f "/app/.radical_sea_bunny/config.json" ]; then
    echo "📝 Creating default configuration..."
    mkdir -p /app/.radical_sea_bunny
    cp /app/config/default_config.json /app/.radical_sea_bunny/config.json 2>/dev/null || true
fi

echo "✅ RADICAL SEA BUNNY ready!"
echo "🌐 Web Dashboard: http://localhost:5000"
echo "📱 All platforms: Discord, Slack, Telegram, Signal, iMessage, Google Chat"
echo ""

# Execute the main command
exec "$@"