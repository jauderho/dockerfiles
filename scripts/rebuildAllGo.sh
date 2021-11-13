#!/bin/bash
#
# Script to kick off rebuilding of all Go based images
#
set -euo pipefail
IFS=$'\n\t'

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
