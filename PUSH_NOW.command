#!/bin/bash
cd /Users/bilalkhan/Downloads/Academia-Link-2

echo "Setting up GitHub push..."

# Configure git
git config user.email "build@thehighgrader.app"
git config user.name "Build System"

# Make sure remote is set
git remote remove origin 2>/dev/null
git remote add origin https://github.com/BilalKmohmand/thehighgrader-desktop.git

# Ensure we're on main branch
git branch -M main

# Push
echo ""
echo "Pushing to GitHub..."
echo "If prompted, enter your GitHub username and password (use Personal Access Token)"
echo ""
git push -u origin main

echo ""
read -p "Press Enter to close..."
