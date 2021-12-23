#!/bin/bash
#
# Script to kick off rebuilding of all Go based images
#
set -euo pipefail
IFS=$'\n\t'

REPO=( 
        "age" \
        "ali" \
        "amass" \
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
        "goplay2" \
        "gotip" \
        "hakrawler" \
        "headscale" \
        "httprobe" \
        "httpx" \
        "lego" \
        "miller" \
        "nebula" \
        "octosql" \
        "pwru" \
        "rclone" \
        "spicedb" \
        "subfinder" \
        "tailscale" \
        "terraform" \
        "toxiproxy" \
        "wuzz" \
)

for i in "${REPO[@]}"
do
	gh workflow run "${i}"
done
