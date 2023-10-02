
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/bl3auto/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/bl3auto/latest)](https://github.com/jauderho/bl3auto/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/bl3auto)](https://hub.docker.com/r/jauderho/bl3auto/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/bl3auto/latest)](https://hub.docker.com/r/jauderho/bl3auto/)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.

This will automate the redemption of all available SHiFT codes for all Borderlands and Wonderlands games.

Usage: `docker run -it -v codes:/root/.config/bl3auto/bl3auto ghcr.io/jauderho/bl3auto:latest`

### Docker Compose
```
services:
  bl3auto:
    container_name: bl3auto
    image: jauderho/bl3auto:latest
    command: ["-e", "${BL3_EMAIL}", "-p", "${BL3_PASSWORD}"]
    volumes:
      - './codes:/root/.config/bl3auto/bl3auto'

volumes:
  codes:
```
