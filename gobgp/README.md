
Usage: `docker run --rm -it -v $(pwd):/config ghcr.io/jauderho/gobgp:latest`

Create a `gobgp.toml` in the current directory with the following:
```
[global.config]
  as = 64512
  router-id = "192.168.255.1"

[[neighbors]]
  [neighbors.config]
    neighbor-address = "10.0.255.1"
    peer-as = 65001

[[neighbors]]
  [neighbors.config]
    neighbor-address = "10.0.255.2"
    peer-as = 65002

```

See https://github.com/osrg/gobgp/blob/master/docs/sources/getting-started.md for more details


[![Build Status](https://github.com/jauderho/dockerfiles/workflows/gobgp/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/gobgp/latest)](https://github.com/osrg/gobgp)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/gobgp)](https://hub.docker.com/r/jauderho/gobgp/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/gobgp/latest)](https://hub.docker.com/r/jauderho/gobgp)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.
