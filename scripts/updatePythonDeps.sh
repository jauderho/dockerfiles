#!/bin/bash
#
# Script to check and update requirements for Python apps
#
set -euo pipefail
IFS=$'\n\t'

APP=(
  "ansible" \
  "sslyze" \
)

# setup git
git config user.name "updatebot"
git config user.email "jauderho+update@users.noreply.github.com"
git config pull.rebase false

# setup pipenv and python
#PATH="$HOME/.local/bin:$PATH"
#pipenv install --python 3.9
#pipenv shell

for i in "${APP[@]}"
do
	cd "${i}"

	echo "Updating ${i} ..."
	echo

	pipenv --python 3.9 lock && pipenv --python 3.9 lock -r > requirements.txt
	#pipenv lock && pipenv lock -r > requirements.txt

	git add Pipfile Pipfile.lock requirements.txt && \
	git commit -s -m "Update requirements for ${i} ..." && \
	git pull && \
	git push

	echo
	echo

	cd ..
done

