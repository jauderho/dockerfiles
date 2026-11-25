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
- **npm packages** — the upgrade list is generated at build time by `bun audit`
  rather than maintained by hand, so new advisories are picked up on rebuild
  without editing the Dockerfile. Each entry is applied as a caret (`^`) range,
  so npm resolves the newest SemVer-compatible release (patch/minor only, no
  major bumps). The audit is read-only — it reads `package.json` and
  `package-lock.json` only, and never reinstalls, so the vendored tree and its
  prebuilt native modules (`canvas`, `cpu-features`, `ssh2`) are left intact.
- **glob major upgrade** — `glob` 10 (under `typeorm`) and 13 (under `rimraf`)
  move to 14, the only release with the fix for GHSA-3g3m-2fjr-6pw4: an npm
  override for `typeorm`, and an in-range `rimraf` update (6.1.4+ uses glob 14).
  The build checks that typeorm's entity, subscriber and migration globs find the
  same files and classes before and after; startup, all migrations and the web UI
  were also checked against a TimescaleDB to behave the same as before.
- **npm's own dependencies** — the `undici` and `ip-address` copies bundled inside
  npm are replaced with the newest release of the same major, because the npm
  releases themselves trail those fixes. Its `minimatch` 10 and `glob` 13 move to
  11 and 14 (GHSA-g3hv-75wg-m249, GHSA-3g3m-2fjr-6pw4), which npm only calls
  through APIs the new majors keep; the build runs npm workspace, pack, query,
  run and cache commands afterwards. npm stays in the image because the app runs
  `npm run typeorm:migration:run` at startup and on upgrade.
- **Go binaries** — `linux-router`, `linux-service`, `agent` and `otel-exporter`
  are rebuilt from the upstream source tarball (`xormon-ng-<ver>-source.tar.gz`)
  in a `GOBUILD` stage on the pinned `golang:1.27.4` image, replacing the
  prebuilt ones that embed an old Go standard library. The build generates the
  protobuf code the tarball does not ship (as `xormon.sh` does), moves
  `golang.org/x/net` and `golang.org/x/text` to their latest release, and builds
  static binaries (`CGO_ENABLED=0`, linux/amd64). Grype reports nothing for them.
- **Unused architectures** — the prebuilt Go binaries of every architecture are
  dropped (this image is amd64-only).

Not fixed here: the AIX agent `agent-aix-ppc64` (it cannot be rebuilt here, and it
is only a download for AIX hosts), the copies of
`urllib3`/`msgpack`/`setuptools` vendored inside `pip` (pip is kept because the
analyzer runs `pip freeze`; they clear when pip updates its vendored set), and the
`vega`/`vega-functions` 5.x (XSS fixed only in 6.x). vega 6 uses top-level
`await`, so the app's `require("vega")` (alert e-mail charts) fails with
`ERR_REQUIRE_ASYNC_MODULE`; it needs an upstream change to `import()`. Both
advisories need user-supplied Vega specs in a browser, while this app builds its
specs on the server.

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/xormon-ng/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/xormon-ng/latest)](https://github.com/xorux/xormon-ng)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/xormon-ng)](https://hub.docker.com/r/jauderho/xormon-ng/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/xormon-ng/latest)](https://hub.docker.com/r/jauderho/xormon-ng/)

Up to date images are built an hour after upstream release and rebuilt at least once a week.
