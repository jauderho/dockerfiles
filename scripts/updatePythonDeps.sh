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
#
# uv.lock is the single source of truth; the Dockerfiles install it with
# "uv sync --frozen" and no requirements.txt is generated any more.
#
# UV_CONFIG_FILE points at an empty file on purpose. A user-level
# ~/.config/uv/uv.toml applies to local lock runs but not to CI, and an
# "exclude-newer" setting there silently resolves to downgrades.
: > /tmp/empty-uv.toml
UV_CONFIG_FILE=/tmp/empty-uv.toml uv lock -U

git pull && \
git add pyproject.toml uv.lock && \
git commit -S -s -m "Update requirements for $1 ..." && \
git pull && \
git push

echo
echo

cd ..
