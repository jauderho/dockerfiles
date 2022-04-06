#!/bin/bash
#
# Script to check and start new image builds if the source repos have new releases
#
set -euo pipefail
IFS=$'\n\t'

# $PAT variable needs to be passed into the script as an env variable
# PAT is only used to avoid API rate limits

read -r -d '' -a REPO < <( grep -I -R ARCHIVE_URL= ./*/Dockerfile | sed -e 's/^.*ARG ARCHIVE_URL\=https\:\/\/github.com\///g' -e 's/\/archive\/.*$//g' && printf '\0' )

# setup git
git config user.name "updatebot"
git config user.email "jauderho+update@users.noreply.github.com"
git config pull.rebase false

# Pull in the latest version from GitHub and if there is a newer version, update GitHub Action to trigger a new build
# Right noew it's just a string compare
for i in "${REPO[@]}"
do

	prog=$(echo "$i" | sed -e "s/.*\///")
	dver=$(grep "BUILD_VERSION:" ".github/workflows/${prog}.yml" | cut -d \" -f 2)

	if [ "$i" != "ansible/ansible" ]; then
		#rver=$(curl -sL -u "$PAT" "https://api.github.com/repos/${i}/releases/latest" | grep tag_name | head -1 | cut -d \" -f 4)
		#rver=$(curl -sL -u "$PAT" "https://api.github.com/repos/${i}/tags" | jq -r '.[0].name')
		rver=$(curl -sL -u "$PAT" "https://api.github.com/repos/${i}/releases/latest" | jq -r '.tag_name')
		#rver=$(curl -sL "https://api.github.com/repos/${i}/releases/latest" | grep tag_name | head -1 | cut -d \" -f 4)
		#rver="2021.02.04.1"

	else

		# special case for ansible
		# ansible is a pain and does not put the release tag in the same repo (ansible/ansible) but ansible-community/ansible-build-data instead
		rver=$(curl -sL https://pypi.org/pypi/ansible/json | jq -r '.info.version')
	fi

	echo "Checking repo ... $prog"
	echo 
	echo "    Dockerfile version is $dver"
	echo "    Repo version is	  $rver"
	echo
	
	# Skip if null
	[ -z "$rver" ] && break

	# Version check
	if [ "$dver" != "$rver" ]; then

		# Update python requirements as necessary
		if [ "$i" == "ansible/ansible" ] || [ "$i" == "nabla-c0d3/sslyze" ]; then
			echo
			scripts/updatePythonDeps.sh "$prog"
		fi

		echo "Updating to ${rver} ..." 

		sed -i -e "s/\"$dver\"/\"$rver\"/" ".github/workflows/${prog}.yml" && \
		git add ".github/workflows/${prog}.yml" && \
		git commit -s -m "Updated ${prog} to ${rver}" && \
		git push

	else
		echo "No update needed ..."
	fi

	echo
	echo
	echo
done

