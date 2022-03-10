
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/tailscale/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Atailscale)
[![Version](https://img.shields.io/docker/v/jauderho/tailscale/latest)](https://github.com/tailscale/tailscale)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/tailscale)](https://hub.docker.com/r/jauderho/tailscale/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/tailscale/latest)](https://hub.docker.com/r/jauderho/tailscale/)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.

## Docker Compose (recommended)

```
# Compose file created with autocompose and https://hub.docker.com/r/nfrede/tailscale

services:
  tailscale:
    container_name: tailscale
    image: jauderho/tailscale:latest
    restart: unless-stopped
    command:
      - tailscaled
    cap_add:
      - NET_ADMIN
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv6.conf.all.forwarding=1
    volumes:
      - ./config:/var/lib/tailscale
      - /dev/net/tun:/dev/net/tun
```

Store environment variables in .env:

```
HOSTNAME=<CUSTOM-HOSTNAME>
ACCEPTDNS=true/false
ACCEPTROUTES=true/false
ADVERTISEROUTES=<ROUTES-GO-HERE>
AUTHKEY=<MAGIC-GOES-HERE>
```

To see status:
`docker exec tailscale tailscale status`
