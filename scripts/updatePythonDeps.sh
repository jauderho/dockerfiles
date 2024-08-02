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

# setup pipenv and python
#PATH="$HOME/.local/bin:$PATH"
#pipenv install --python 3.9
#pipenv shell
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends pipenv python3.12
#DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends pipenv 

cd "$1"

echo "Updating $1 ..."
echo

# for python3.10 and ubuntu 22.04
#python -m pip install -U pip
#python -m pip install -U setuptools
python3.12 -m pip install --no-cache-dir --upgrade pip --break-system-packages
python3.12 -m pip install --no-cache-dir --upgrade --user pipenv certifi wheel setuptools packaging --break-system-packages
#python3.11 -m pip install --no-cache-dir --upgrade --user pipenv
#python3.11 -m pip install --no-cache-dir --upgrade --user certifi
#pipenv lock && pipenv requirements > requirements.txt
pipenv --python 3.12 lock && pipenv --python 3.12 requirements > requirements.txt

git add Pipfile Pipfile.lock requirements.txt && \
git commit -S -s -m "Update requirements for $1 ..." && \
git pull && \
git push

echo
echo

cd ..
