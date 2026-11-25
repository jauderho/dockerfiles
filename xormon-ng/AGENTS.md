# xormon-ng: notes for agents

These notes add to the repository root `AGENTS.md`. Read `Dockerfile` and `README.md` before you change anything. The comments in `Dockerfile` explain each step.

## Facts

- Upstream ships a closed tarball: `https://xormon.com/download-static/xormon-ng/xormon-ng-<ver>.tar.gz`. It has no GitHub releases and no source for the Node `dist/` code. The Go source is in a second tarball, `xormon-ng-<ver>-source.tar.gz` (same directory; the download page links it through a registration form, but the static URL works). The `GOBUILD` stage rebuilds the Go binaries from it.
- The source tarball has no generated protobuf code and its `go.sum` files are incomplete. `GOBUILD` runs `protoc` (as `xormon.sh` does) and `go mod tidy`. If upstream adds a Go module or changes how `xormon.sh` builds, change `GOBUILD` to match.
- `BUILD_VERSION` is set in `.github/workflows/xormon-ng.yml`. `scripts/updateDockerImages.sh` (`resolve_xormon`) updates it by reading `xormon.com/download.php`.
- The image is amd64 only. It uses Ubuntu (glibc) and the official Node 24 tarball, not Alpine. The prebuilt native modules (`canvas`, `cpu-features`, `ssh2`) need glibc and cannot be rebuilt.
- At startup, `startup.sh` runs `npm run start:runtime`, which runs `node dist/verify.js` (TypeORM migrations) and then `pm2-runtime`. So npm must stay in the image.
- The app needs an external TimescaleDB, set with the `DB_*` variables. The image does not include a database.

## Rules

- **Never re-resolve or rebuild `node_modules`.** Do not use `npm audit fix`, `bun audit fix`, a plain `npm install`, or `npm ci`. A full install rebuilds `canvas` with node-gyp, and that fails. Use only the patterns in the Dockerfile:
  - A bun audit dry run gives the in-major list, and each package is swapped in place.
  - npm `overrides` with `--omit=dev --ignore-scripts --prefer-offline`.
- Same-major upgrades are automatic. A major upgrade needs:
  1. Proof that the app's calls still work: a build-time check such as the glob before/after `cmp`.
  2. A runtime test (below).
  3. An update to `README.md` ("Security hardening" / "Not fixed").
- The packages bundled inside npm (`undici`, `ip-address`, `minimatch`, `glob`) are replaced on purpose because npm releases trail the fixes. After you swap one, run the npm smoke test in the same `RUN`.
- Keep the `bun` stage as a bind mount only. `/usr/local` is copied whole into the runtime image, so anything installed there ships.

## Known blockers (do not retry without new facts)

- **vega / vega-functions 6:**
  - vega 6 is ESM with top-level `await`, so `require("vega")` fails. Node 24 gives `ERR_REQUIRE_ASYNC_MODULE`, and Bun 1.4.5 fails too.
  - It needs an upstream change to `import()`.
- **`agent-aix-ppc64`:** the AIX binary keeps its old Go stdlib. It is not rebuilt here.
- **nodemailer, pm2, uuid 8:** these need a major upgrade and have not been tested.
- **pip's vendored urllib3/msgpack/setuptools:** pip must stay because the analyzer runs `pip freeze`.

## Build and test

Build on a native amd64 Docker host, not under emulation:

```bash
docker build --build-arg BUILD_VERSION=<ver> -t xormon-ng:test xormon-ng
```

The build checks itself and fails on a bad change. It looks for:
- `npm-patch:` and `npm-major:` lines, which show each version change.
- npm smoke test failures.
- The glob `cmp` check.
- Unusable bun audit JSON.

For any change beyond a same-major upgrade, also run a runtime test. Run it against both the new image and the published `ghcr.io/jauderho/xormon-ng:latest`:

1. Start `timescale/timescaledb:latest-pg16` and xormon-ng with `DB_HOST`, `DB_PASSWORD` and `APP_SECRET` set.
2. After about 60 s, check that `https://localhost:8443` returns 200 and a bad login returns 401.
3. In the container, as `xormon` in `server-nest`, run `npm run typeorm:migration:run`. It must report "No migrations are pending".
4. Compare the error lines in `docker logs` for the two images. They must match. The otel-exporter and xormon-agent ENOENT errors are already present in the published image.
5. Run Grype on both images (`docker run anchore/grype <image>`) to count the vulnerabilities fixed and added.

## Code scanning

The alert categories are `anchore-xormon-ng` (Grype) and `trivy-xormon-ng`. Scans run daily from `scan.yml`, so alert counts change only after a scan that runs after the image is pushed. Most Grype alerts are on Ubuntu packages (`/var/lib/dpkg/status`) that have no fixed release yet. `dist-upgrade` clears them once Ubuntu ships a fix. The rest are on npm `package.json` files (vega). The Go binary alerts (stdlib, `golang.org/x/net`, `golang.org/x/text`) clear once the `GOBUILD` rebuild is published and scanned.
