
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/cloudflared/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/cloudflared/latest)](https://github.com/cloudflare/cloudflared)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/cloudflared)](https://hub.docker.com/r/jauderho/cloudflared/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/cloudflared/latest)](https://hub.docker.com/r/jauderho/cloudflared/)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.

Usage: `docker run --rm -it ghcr.io/jauderho/cloudflared:latest`

### docker compose

```
services:
  cloudflared:
    container_name: cloudflared
    image: jauderho/cloudflared:latest
    ports:
      - "5454:5454/tcp"
      - "5454:5454/udp"
    volumes:
       - './etc-cloudflared/:/etc/cloudflared/'
    # uncomment if using a lower port
    #cap_add:
    #  - NET_BIND_SERVICE
    restart: unless-stopped
```

etc-cloudflared/config.yaml
```yaml
no-autoupdate: true
max-upstream-conns: 75
protocol: quic
proxy-dns: true
proxy-dns-address: 0.0.0.0
proxy-dns-port: 5454
proxy-dns-upstream:
    #- https://mozilla.cloudflare-dns.com/dns-query
    - https://odoh.cloudflare-dns.com/dns-query
    - https://9.9.9.9/dns-query
    - https://doh.la.ahadns.net/dns-query
    #- https://n69pt178tv.cloudflare-gateway.com/dns-query
