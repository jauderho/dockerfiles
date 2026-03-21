#!/bin/bash
#
# Script to check and update requirements for Python apps
#
set -euo pipefail
IFS=$'\n\t'

# setup git
#git config --local user.name "Jauder Ho Bot"
#git config --local user.email "jauderho-bot@users.noreply.github.com"
#git config --local pull.rebase false

cd "$1"

echo "Updating $1 ..."
echo

# Build dependencies
uv lock -U && uv pip compile pyproject.toml --no-annotate > requirements.txt

git pull && \
git add pyproject.toml uv.lock requirements.txt && \
git commit -S -s -m "Update requirements for $1 ..." && \
git pull && \
git push

echo
echo

cd ..
