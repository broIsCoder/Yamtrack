#!/bin/bash

echo "Removing tracked heavy directories..."
git rm -r --cached venv 2>/dev/null
git rm -r --cached node_modules 2>/dev/null
git rm -r --cached src/tailwindcss 2>/dev/null
git rm --cached tailwindcss-linux-x64 2>/dev/null
git rm -r --cached playwright/driver 2>/dev/null

echo "Adding .gitignore..."
git add .gitignore

echo "Committing cleanup..."
git commit -m "cleanup: remove large files, add gitignore"

echo "Purging large files from entire Git history..."
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch -r venv node_modules src/tailwindcss tailwindcss-linux-x64 playwright/driver' \
--prune-empty --tag-name-filter cat -- --all

echo "Force pushing cleaned repo..."
git push origin master --force

echo "Repository cleaned and pushed successfully."
