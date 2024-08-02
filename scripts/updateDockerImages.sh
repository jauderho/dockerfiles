#!/bin/bash
#
# Script to check and start new image builds if the source repos have new releases
#
set -euo pipefail
IFS=$'\n\t'

# $PAT variable needs to be passed into the script as an env variable
# PAT is only used to avoid API rate limits

REPO=( 
	"filosottile/age" \
	"nakabonne/ali" \
	"ansible/ansible" \
	"OWASP/amass" \
	"getanteon/anteon" \
	"jauderho/bl3auto" \
	"psf/black" \
	"jauderho/cf-warp" \
	"cloudflare/cloudflared" \
	"coredns/coredns" \
	"StackExchange/dnscontrol" \
	"DNSCrypt/dnscrypt-proxy" \
	"projectdiscovery/dnsx" \
	"cloudskiff/driftctl" \
	"moncho/dry" \
	"multiprocessio/dsq" \
	"wader/fq" \
	"osrg/gobgp" \
	"kffl/gocannon" \
	"buger/goreplay" \
	"tomnomnom/gron" \
	"juanfont/headscale" \
	"nojima/httpie-go" \
	"projectdiscovery/httpx" \
	"go-acme/lego" \
	"0xInfection/logmepwn" \
	"johnkerl/miller" \
	"slackhq/nebula" \
	"gravitl/netmaker" \
	"binwiederhier/ntfy" \
	"cube2222/octosql" \
	"aramperes/onetun" \
	"opentofu/opentofu" \
	"prettier/prettier" \
	"cilium/pwru" \
	"rclone/rclone" \
	"astral-sh/ruff" \
	"authzed/spicedb" \
	"jtesta/ssh-audit" \
	"nabla-c0d3/sslyze" \
	"projectdiscovery/subfinder" \
	"tailscale/tailscale" \
	"hashicorp/terraform" \
	"drwetter/testssl.sh" \
	"shopify/toxiproxy" \
	"trufflesecurity/trufflehog" \
	"tsenart/vegeta" \
	"saulpw/visidata" \
	"likexian/whois" \
	"yggdrasil-network/yggdrasil-go" \
	"ytdl-org/youtube-dl" \
	"yt-dlp/yt-dlp" \
	"yt-dlp/yt-dlp-nightly-builds" \
	"getzola/zola" \
)

# setup git
#git config --local user.name "Jauder Ho Bot"
#git config --local user.email "jauderho-bot@users.noreply.github.com"
#git config --local pull.rebase false

# Fetch the latest version from GitHub and if there is a newer version, update GitHub Action to trigger a new build
# Right now it is just a string compare
for i in "${REPO[@]}"
do

	prog=$(echo "$i" | sed -e "s/.*\///")
	dver=$(grep "BUILD_VERSION:" ".github/workflows/${prog}.yml" | cut -d \" -f 2)

	case $i in
		"ansible/ansible")
			# special case for ansible
			# ansible is a pain and does not put the release tag in the same repo (ansible/ansible) but ansible-community/ansible-build-data instead
			rver=$(curl -sL https://pypi.org/pypi/ansible/json | jq -r '.info.version')
			;;
		*)
			#rver=$(curl -sL -u "$PAT" "https://api.github.com/repos/${i}/releases/latest" | grep tag_name | head -1 | cut -d \" -f 4)
			#rver=$(curl -sL -u "$PAT" "https://api.github.com/repos/${i}/tags" | jq -r '.[0].name')
			rver=$(curl -sL -u "$PAT" "https://api.github.com/repos/${i}/releases/latest" | jq -r '.tag_name')
			#rver=$(curl -sL "https://api.github.com/repos/${i}/releases/latest" | grep tag_name | head -1 | cut -d \" -f 4)
			#rver="2021.02.04.1"
			;;
	esac

	echo "Checking repo ... $prog"
	echo 
	echo "    Dockerfile version is $dver"
	echo "    Repo version is	  $rver"
	echo
	
	# Skip if null
	[ -z "$rver" ] && break
	[[ $rver = null ]] && break

	# Version check
	if [ "$dver" != "$rver" ]; then

		# Update python requirements as necessary
		case $i in 			
			"ansible/ansible" | \
			"astral-sh/ruff" | \
			"nabla-c0d3/sslyze" | \
			"saulpw/visidata")
				echo
				scripts/updatePythonDeps.sh "$prog"
				;;
			*)
				# not a Python program
				;;
		esac

		echo "Updating to ${rver} ..." 

		sed -i -e "s/\"$dver\"/\"$rver\"/" ".github/workflows/${prog}.yml" && \
		git add ".github/workflows/${prog}.yml" && \
		git commit -S -m "Updated ${prog} to ${rver}" && \
		git push

	else
		echo "No update needed ..."
	fi

	echo
	echo
	echo
done
