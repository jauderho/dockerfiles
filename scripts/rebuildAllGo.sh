#!/bin/bash
#
# Script to kick off rebuilding of all Go based images
#
set -euo pipefail
IFS=$'\n\t'

ACTION=( 
        "age" \
        "ali" \
        "amass" \
        "bl3auto" \
        "cloudflared" \
        "coredns" \
        "ddosify" \
        "dive" \
        "dnscontrol" \
        "dnscrypt-proxy" \
        "dnsx" \
        "driftctl" \
        "dry" \
        "dsq" \
        "fq" \
        "gobgp" \
        "gocannon" \
        "goplay2" \
        "goreplay" \
        "gotip" \
        "gron" \
        "hakrawler" \
        "headscale" \
        "httprobe" \
        "httpie-go" \
        "httpx" \
        "lego" \
        "logmepwn" \
        "miller" \
        "nebula" \
        "netmaker" \
        "ntfy" \
        "octosql" \
        "pwru" \
        "rclone" \
        "rdap" \
        "spicedb" \
        "subfinder" \
        "tailscale" \
        "terraform" \
        "textql" \
        "toxiproxy" \
        "trufflehog" \
        "vegeta" \
        "watchtower" \
        "whois" \
        "wuzz" \
        "yggdrasil-go" \
)

for i in "${ACTION[@]}"
do
	gh workflow run "${i}"
done
