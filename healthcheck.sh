#!/bin/sh
# RADICAL SEA BUNNY - Health Check Script

# Check if the process is running
if pgrep -f "radical_sea_bunny.py" > /dev/null; then
    # Check if web server is responding
    if curl -s -f http://localhost:5000/api/status > /dev/null 2>&1; then
        echo "✅ RADICAL SEA BUNNY is healthy"
        exit 0
    else
        echo "⚠️ Web server not responding"
        exit 1
    fi
else
    echo "❌ RADICAL SEA BUNNY process not running"
    exit 1
fi