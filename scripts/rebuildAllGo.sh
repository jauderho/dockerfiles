#!/bin/bash
#
# Script to check and start new image builds if the source repos have new releases
#
set -euo pipefail
IFS=$'\n\t'

# $PAT variable needs to be passed into the script as an env variable
# PAT is only used to avoid API rate limits

REPO=( 
        "age" \
        "ali" \
        "bl3auto" \
        "cloudflared" \
        "coredns" \
        "dive" \
        "dnscontrol" \
        "dnscrypt-proxy" \
        "driftctl" \
        "dry" \
        "excalidraw" \
        "gobgp" \
        "gocannon" \
        "headscale" \
        "lego" \
        "miller" \
        "nebula" \
        "octosql" \
        "pwru" \
        "spicedb" \
        "tailscale" \
        "terraform" \
        "wuzz" \
)

for i in "${REPO[@]}"
do
	gh workflow run "${i}"
done
