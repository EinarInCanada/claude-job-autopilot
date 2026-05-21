#!/bin/bash
# Run this once from Terminal to push claude-job-autopilot to GitHub.
# Prerequisites:
#   1. Create the repo on GitHub first:
#      https://github.com/new  →  name: claude-job-autopilot, Public, NO README/gitignore
#   2. Make sure you have git + GitHub auth set up (SSH key or gh CLI)

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

# Remove any stale lock files from previous failed runs
rm -f .git/index.lock 2>/dev/null || true

# Set remote and push
git remote add origin git@github.com:YourGitHubUsername/claude-job-autopilot.git
git push -u origin main

echo ""
echo "✓ Pushed to https://github.com/YourGitHubUsername/claude-job-autopilot"
