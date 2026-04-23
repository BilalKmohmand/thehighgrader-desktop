#!/bin/bash
# Quick Start Script for Academia Link Desktop App
# Run this script to start both backend and desktop app

cd "$(dirname "$0")"

echo "=========================================="
echo "  Academia Link Desktop App Launcher"
echo "=========================================="
echo ""

# Install root dependencies if missing
if [ ! -d "node_modules" ]; then
    echo "[1/4] Installing backend dependencies..."
    echo "This may take 2-3 minutes on first run..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install backend dependencies"
        exit 1
    fi
    echo "✅ Backend dependencies installed"
else
    echo "[1/4] Backend dependencies already installed"
fi

# Install frontend dependencies if missing
if [ ! -d "welcome-hub-main/node_modules" ]; then
    echo "[2/4] Installing frontend dependencies..."
    echo "This may take 2-3 minutes on first run..."
    cd welcome-hub-main
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install frontend dependencies"
        exit 1
    fi
    cd ..
    echo "✅ Frontend dependencies installed"
else
    echo "[2/4] Frontend dependencies already installed"
fi

# Start backend in background
echo "[3/4] Starting Backend Server..."
npx tsx -r dotenv/config server/index.ts &
BACKEND_PID=$!

# Wait for backend to be ready
echo "⏳ Waiting for backend to start..."
for i in {1..30}; do
    if curl -s http://localhost:5050/health > /dev/null 2>&1; then
        echo "✅ Backend is running on port 5050"
        break
    fi
    sleep 1
done

# Check if backend is actually running
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "❌ Backend failed to start. Check for errors above."
    exit 1
fi

echo ""
echo "[4/4] Starting Desktop App..."
cd welcome-hub-main
npm run desktop:dev

# Cleanup when desktop closes
echo ""
echo "🛑 Shutting down backend..."
kill $BACKEND_PID 2>/dev/null

echo "✅ Done!"
