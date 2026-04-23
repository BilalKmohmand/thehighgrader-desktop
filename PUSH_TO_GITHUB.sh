#!/bin/bash
# Push to GitHub script

cd /Users/bilalkhan/Downloads/Academia-Link-2

# Configure git
git config user.email "build@thehighgrader.app"
git config user.name "Build System"

# Initialize repo if not already
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit with desktop app" || echo "Already committed"

# Add remote
git remote remove origin 2>/dev/null
git remote add origin https://github.com/BilalKmohmand/thehighgrader-desktop.git

# Push
git branch -M main
git push -u origin main

echo ""
echo "If prompted, enter your GitHub username and password/token"
echo "To create a token: https://github.com/settings/tokens"
