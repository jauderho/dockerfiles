# XorMon NG
This is a dockerized version of [XoruX](https://www.xorux.com)'s next-generation
unified monitoring frontend - [XorMon NG](https://xormon.com).

It is built from the official XorMon NG `tar.gz` on top of [Ubuntu](https://hub.docker.com/_/ubuntu)
(glibc) with Node.js 24 and only the necessary runtime dependencies. The image is
slimmed down (source maps and non-amd64 artifacts removed) and is **amd64-only**,
matching upstream.

## Requirements

XorMon NG stores its metrics in an **external TimescaleDB** (PostgreSQL 16/17 with
the TimescaleDB extension). The database is intentionally **not** bundled - run it
as a separate container and point XorMon NG at it.

Quick start (with a TimescaleDB sidecar):

    docker run -d --name timescaledb --restart always \
      -e POSTGRES_PASSWORD=secret \
      -v timescaledb:/var/lib/postgresql/data \
      timescale/timescaledb:latest-pg16

    docker run -d --name xormon --restart always \
      --link timescaledb:timescaledb \
      -p 8443:8443 -p 8162:8162 \
      -v xormon:/home/xormon/xormon-ng/server-nest/files \
      -e DB_HOST=timescaledb \
      -e DB_PASSWORD=secret \
      -e APP_SECRET=my-xormon-secret \
      ghcr.io/jauderho/xormon-ng

Supported environment variables (with defaults):

| Variable      | Default     | Description                                    |
| ------------- | ----------- | ---------------------------------------------- |
| `APP_PORT`    | `8443`      | Web UI port (HTTPS)                            |
| `DB_HOST`     | `127.0.0.1` | TimescaleDB host                               |
| `DB_PORT`     | `5432`      | TimescaleDB port                               |
| `DB_USERNAME` | `postgres`  | TimescaleDB user                               |
| `DB_DATABASE` | `xormon`    | TimescaleDB database name                      |
| `DB_PASSWORD` | (empty)     | TimescaleDB password (required)                |
| `APP_SECRET`  | (random)    | App secret; set a fixed value for stable sessions |
| `TIMEZONE`    | `Etc/UTC`   | Container timezone                             |

Application UI is available on https://\<CONTAINER_IP\>:8443, use admin/admin for
the first login.

---

## Security hardening

Official images use an out of date base image with vulnerabilities hence the need
for this image. On top of that, this build applies the following fixes that do not
require recompiling upstream:

- **OS packages** — `apt-get dist-upgrade` patches all base-image packages to the
  latest security releases on every rebuild.
- **TLS certificate** — the shipped static self-signed key is removed; a unique
  cert is generated at container startup instead (no private key baked into the image).
- **npm packages** — vulnerable runtime dependencies are upgraded via caret (`^`)
  ranges, picking up the newest SemVer-compatible release (patch/minor only, no
  major bumps). See the patch step in `Dockerfile` for the list.

Not fixed here: the compiled Go binaries (`agent`, `linux-service`, `linux-router`)
and a few major-bump-only npm packages (`nodemailer`, `pm2`, bundled `uuid` 8.x,
`vega`/`vega-functions` 5.x — XSS fixed only in 6.x), which would need an upstream
rebuild or a breaking version bump.

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/xormon-ng/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/xormon-ng/latest)](https://github.com/xorux/xormon-ng)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/xormon-ng)](https://hub.docker.com/r/jauderho/xormon-ng/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/xormon-ng/latest)](https://hub.docker.com/r/jauderho/xormon-ng/)

Up to date images are built an hour after upstream release and rebuilt at least once a week.
