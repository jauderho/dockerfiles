
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/dnscrypt-proxy/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/dnscrypt-proxy/latest)](https://hub.docker.com/r/jauderho/dnscrypt-proxy/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/dnscrypt-proxy)](https://hub.docker.com/r/jauderho/dnscrypt-proxy/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/dnscrypt-proxy/latest)](https://hub.docker.com/r/jauderho/dnscrypt-proxy/)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.

This is a dnscrypt-proxy build forked from https://github.com/klutchell/dnscrypt-proxy

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
    cap_add:
      - NET_BIND_SERVICE
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
```
