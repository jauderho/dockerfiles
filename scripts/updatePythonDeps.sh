#!/bin/bash
#
# Script to check and update requirements for Python apps
#
set -euo pipefail
IFS=$'\n\t'

# setup git
git config user.name "Jauder Ho"
git config user.email "jauderho@users.noreply.github.com"
git config pull.rebase false

# setup pipenv and python
#PATH="$HOME/.local/bin:$PATH"
#pipenv install --python 3.9
#pipenv shell
#DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends pipenv python3.11
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends pipenv 

cd "$1"

echo "Updating $1 ..."
echo

# for python3.10 and ubuntu 22.04
#python -m pip install -U pip
#python -m pip install -U setuptools
python3 -m pip install --no-cache-dir --upgrade pip
pip install --upgrade --user pipenv
pip install --upgrade --user certifi
pipenv lock && pipenv requirements > requirements.txt
#pipenv --python 3.11 lock && pipenv --python 3.11 requirements > requirements.txt

git add Pipfile Pipfile.lock requirements.txt && \
git commit -s -m "Update requirements for $1 ..." && \
git pull && \
git push

echo
echo

cd ..
