#!/bin/bash

# Navigate to the project directory
cd /home/alex/Downloads/phpass/

# 1. Check if token was passed
GIT_TOKEN=$1
if [ -z "$GIT_TOKEN" ]; then
    echo "Error: You must provide your GitHub token."
    echo "Usage: ./deploy.sh ghp_YOUR_TOKEN_HERE"
    exit 1
fi

# 2. Reset and Push
rm -rf .git
git init
git config user.name "Alex"
git config user.email "alex@local"
git add .
git commit -m "Simple upload"
git branch -M main
git remote add origin https://alm153794:$GIT_TOKEN@github.com/alm153794/project.git
git push -u origin main --force

echo "-------------------------------------------------------"
echo "Success! Your code is on GitHub."
echo "Open Codespaces here: https://github.com/alm153794/project/codespaces"