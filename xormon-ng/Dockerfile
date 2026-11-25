#!/usr/bin/docker build .
#
# VERSION               1.0

# ---------------------------------------------------------------------------
# bun - build-time only. Supplies "bun audit", which generates the npm upgrade
# list further down. Bind-mounted into that one step rather than COPY, so the
# 80MB binary never lands in a layer (the runtime stage copies /usr/local
# wholesale, so anything installed there would ship).
# ---------------------------------------------------------------------------
FROM oven/bun:1.4.5@sha256:3aa040e5445efa09d75bb428a64ba50db13e2b3ac9b6b0c7f145615f62b2ee18 AS bun

# ---------------------------------------------------------------------------
# GOBUILD - rebuild the Go binaries (linux-router, linux-service, agent,
# otel-exporter) from the upstream source tarball. The prebuilt ones in the
# application tarball embed an old Go standard library and old golang.org/x/*
# modules, so they are replaced with ones built by the current toolchain and
# with golang.org/x/net and golang.org/x/text at their latest release. Upstream
# does not ship the generated protobuf code, so it is generated here the same
# way xormon.sh does. The binaries are static (CGO off) and built for linux/amd64.
# ---------------------------------------------------------------------------
FROM golang:1.27.4@sha256:5f1b98fa02fe396ebce2a0227a0e08309e11792915b9dd2e1f71053d7e7e6666 AS GOBUILD

ARG BUILD_VERSION
ARG DEBIAN_FRONTEND=noninteractive
# protobuf generators, matching the google.golang.org/protobuf version in the
# upstream go.mod files (protoc-gen-go) and the newest protoc-gen-go-grpc
ARG PROTOC_GEN_GO_VERSION=v1.36.12
ARG PROTOC_GEN_GO_GRPC_VERSION=v1.6.2

RUN apt-get update \
    && apt-get install -y --no-install-recommends protobuf-compiler libprotobuf-dev \
    && rm -rf /var/lib/apt/lists/* \
    && go install "google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GEN_GO_VERSION}" \
    && go install "google.golang.org/grpc/cmd/protoc-gen-go-grpc@${PROTOC_GEN_GO_GRPC_VERSION}"

# Source tarball: content sits at the archive root. Only the Go trees are used.
ADD https://xormon.com/download-static/xormon-ng/xormon-ng-${BUILD_VERSION}-source.tar.gz /tmp/xormon-ng-source.tar.gz
RUN mkdir /src /out \
    && tar xzf /tmp/xormon-ng-source.tar.gz -C /src \
       server-nest/microservices/linux-go server-nest/src/otel-exporter \
    && rm /tmp/xormon-ng-source.tar.gz

# linux-router, linux-service and agent (three modules; the last two replace
# linux-go with the root module, whose linux-grpc package is generated here).
# "go get" moves x/net and x/text to their latest release and updates go.sum;
# the build fails if the result does not compile.
WORKDIR /src/server-nest/microservices/linux-go
RUN set -eux; \
    protoc -I . --experimental_allow_proto3_optional \
        --go_out=. --go_opt=paths=source_relative \
        --go-grpc_out=. --go-grpc_opt=paths=source_relative \
        linux-grpc/linux.proto linux-grpc/metadata.proto; \
    for m in . linux-service agent; do \
        (cd "$m" && go get golang.org/x/net golang.org/x/text && go mod tidy); \
    done; \
    export CGO_ENABLED=0 GOOS=linux GOARCH=amd64; \
    go build -trimpath -ldflags "-s -w" -o /out/linux-router router.go; \
    (cd linux-service && go build -trimpath -ldflags "-s -w" -o /out/linux-service .); \
    (cd agent && go build -trimpath -ldflags "-s -w" -o /out/agent .)

# otel-exporter (named otel-exporter-amd64 like upstream; post-upgrade.js copies
# it to otel-exporter at start-up)
WORKDIR /src/server-nest/src/otel-exporter
RUN set -eux; \
    pb=otel-exporter/internal/otlppb; \
    protoc -I otel-proto --experimental_allow_proto3_optional \
        --go_out=. --go_opt=module=otel-exporter \
        --go_opt=Mopentelemetry/proto/common/v1/common.proto="$pb/common/v1" \
        --go_opt=Mopentelemetry/proto/resource/v1/resource.proto="$pb/resource/v1" \
        --go_opt=Mopentelemetry/proto/metrics/v1/metrics.proto="$pb/metrics/v1" \
        --go_opt=Mopentelemetry/proto/collector/metrics/v1/metrics_service.proto="$pb/collector/metrics/v1" \
        otel-proto/opentelemetry/proto/common/v1/common.proto \
        otel-proto/opentelemetry/proto/resource/v1/resource.proto \
        otel-proto/opentelemetry/proto/metrics/v1/metrics.proto \
        otel-proto/opentelemetry/proto/collector/metrics/v1/metrics_service.proto; \
    go get golang.org/x/text && go mod tidy; \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
        go build -trimpath -ldflags "-s -w" -o /out/otel-exporter-amd64 .

# ---------------------------------------------------------------------------
# Stage 1: build - download Node.js + the XorMon NG tarball, prune, build venv
# ---------------------------------------------------------------------------
FROM ubuntu:26.10@sha256:1c2a84ae3f2a24aeb97cded5b41f0211b441662f1a188cbd2e139e7625f6f1d6 AS build

ARG BUILD_VERSION
ARG NODE_VERSION=24.22.3
# npm is upgraded past the version bundled with Node: older bundles (11.17.0)
# vendor tar 7.5.16, while npm 11.18.0+ vendors tar 7.5.19, which carries the
# fix for GHSA-23hp-3jrh-7fpw.
ARG NPM_VERSION=^11.19.0
ARG DEBIAN_FRONTEND=noninteractive

# build-only tooling (never lands in the final image)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    python3 \
    python3-venv \
    python3-dev \
    build-essential \
    libpq-dev \
    libdbi-perl \
    unixodbc-dev \
    libcrypt-dev \
    cpanminus \
    libtest-output-perl \
    libcapture-tiny-perl \
    && rm -rf /var/lib/apt/lists/*

# DBD::ODBC (SQL Server monitoring) was dropped from the Ubuntu 26.10 archive.
# Build it from the pinned CPAN tarball (sha256-checked, no index lookup) into
# /usr/local (default site perl dir), which the runtime stage copies wholesale. Links libodbc.so.2, provided by runtime unixodbc.
ARG DBD_ODBC_URL=https://cpan.metacpan.org/authors/id/M/MJ/MJEVANS/DBD-ODBC-1.61.tar.gz
ARG DBD_ODBC_SHA256=96def438c9610d72d0e24d007ea0eacd0059b5203c17eadb623bdea22fa9f40a
RUN curl -fsSL --proto "=https" --proto-redir "=https" "${DBD_ODBC_URL}" -o /tmp/dbd-odbc.tar.gz \
    && echo "${DBD_ODBC_SHA256}  /tmp/dbd-odbc.tar.gz" | sha256sum -c - \
    && cpanm --notest /tmp/dbd-odbc.tar.gz \
    && rm -rf /tmp/dbd-odbc.tar.gz /root/.cpanm /usr/local/man /usr/local/lib/*/perl/*/perllocal.pod

# Node.js 24 (glibc prebuilt) into /usr/local; drop C++ headers/docs (only
# needed to compile native addons, which we never do at runtime) - saves ~63MB
RUN curl -fsSL --proto "=https" --proto-redir "=https" \
        "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz \
    && tar xf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz \
    && npm install -g "npm@${NPM_VERSION}" --no-audit --no-fund \
    && rm -rf /usr/local/include /usr/local/CHANGELOG.md /usr/local/README.md \
       /usr/local/lib/node_modules/npm/docs /usr/local/lib/node_modules/npm/man \
    # the prebuilt node binary carries its symbol table (~18MB). Nothing here
    # profiles or debugs the runtime natively, and JS stack traces are
    # unaffected - those come from V8, not ELF symbols.
    && strip --strip-unneeded /usr/local/bin/node \
    && node -v \
    && npm -v

# npm bundles its own copies of undici and ip-address, which trail their security
# fixes (both are flagged in the image scan, and neither npm 11.21 nor 12.2 ships
# the patched releases). Swap in the newest release of the same major so the
# bundled tree stays API-compatible, then check npm still runs.
RUN set -eux; \
    nm=/usr/local/lib/node_modules/npm/node_modules; \
    work="$(mktemp -d)"; \
    for pkg in undici ip-address; do \
        major="$(node -p "require('$nm/$pkg/package.json').version.split('.')[0]")"; \
        rm -rf "$work/pkg" "$work"/*.tgz; mkdir "$work/pkg"; \
        (cd "$work" && npm pack "$pkg@^$major" --silent >/dev/null && tar xzf ./*.tgz -C pkg --strip-components=1); \
        old="$(node -p "require('$nm/$pkg/package.json').version")"; \
        new="$(node -p "require('$work/pkg/package.json').version")"; \
        rm -rf "$nm/$pkg"; mkdir "$nm/$pkg"; cp -a "$work/pkg/." "$nm/$pkg/"; \
        echo "npm-patch: $pkg $old -> $new"; \
    done; \
    rm -rf "$work" /root/.npm; \
    npm -v; \
    npm view lodash version

# npm's bundled minimatch 10 (GHSA-g3hv-75wg-m249) and glob 13
# (GHSA-3g3m-2fjr-6pw4) are fixed only in minimatch 11 and glob 14, which no npm
# release bundles yet. npm calls only minimatch(), minimatch.match(),
# Minimatch#match, glob() and globSync(), which both new majors keep. Each is
# installed with its own dependencies nested under it, so nothing else in npm's
# tree changes. The npm commands after the swap exercise every caller:
# workspaces (map-workspaces, get-workspaces), pack (ignore-walk, bin directory
# normalization), query (arborist), cache verify (cacache) and run.
RUN set -eux; \
    nm=/usr/local/lib/node_modules/npm/node_modules; \
    for spec in "minimatch@^11.0.9" "glob@^14.0.6"; do \
        pkg="${spec%@*}"; \
        work="$(mktemp -d)"; \
        npm install --prefix "$work" "$spec" --ignore-scripts --no-audit --no-fund --silent; \
        old="$(node -p "require('$nm/$pkg/package.json').version")"; \
        rm -rf "$nm/$pkg"; \
        mv "$work/node_modules/$pkg" "$nm/$pkg"; \
        rm -rf "$work/node_modules/.bin" "$work/node_modules/.package-lock.json"; \
        mkdir "$nm/$pkg/node_modules"; \
        mv "$work/node_modules/"* "$nm/$pkg/node_modules/"; \
        echo "npm-patch: $pkg $old -> $(node -p "require('$nm/$pkg/package.json').version")"; \
        rm -rf "$work" /root/.npm; \
    done; \
    cd "$(mktemp -d)"; \
    printf '{"name":"t","version":"1.0.0","workspaces":["packages/*"]}' > package.json; \
    mkdir -p packages/a/bin; \
    printf '{"name":"a","version":"1.0.0","files":["*.js","bin"],"directories":{"bin":"bin"},"scripts":{"t":"echo ok"}}' > packages/a/package.json; \
    echo 'module.exports=1' > packages/a/index.js; echo x > packages/a/skip.txt; \
    printf '#!/usr/bin/env node\n' > packages/a/bin/a-cli; \
    npm pack -w a --dry-run > out.txt 2>&1; \
    grep -q 'index.js' out.txt; \
    grep -q 'bin/a-cli' out.txt; \
    ! grep -q 'skip.txt' out.txt; \
    npm run t -w a > out.txt; \
    grep -q ok out.txt; \
    npm install --ignore-scripts --no-audit --no-fund --silent; \
    npm query '.workspace' > out.txt; \
    grep -q '"name": "a"' out.txt; \
    npm view lodash version; \
    npm cache verify; \
    cd /; rm -rf /root/.npm /tmp/tmp.*

# XorMon NG application tarball (content sits at archive root, no version dir)
ADD https://xormon.com/download-static/xormon-ng/xormon-ng-${BUILD_VERSION}.tar.gz /tmp/xormon-ng.tar.gz
RUN mkdir -p /opt/xormon-ng \
    && tar xzf /tmp/xormon-ng.tar.gz -C /opt/xormon-ng \
    && rm /tmp/xormon-ng.tar.gz

# Prune for a lean, amd64-only image
WORKDIR /opt/xormon-ng
RUN set -eux; \
    # source maps are not used at runtime (~257MB)
    find . -name '*.map' -delete; \
    # drop the prebuilt Go binaries of every architecture (~78MB saved): the
    # amd64 ones are replaced by the GOBUILD rebuilds copied in below. Discover
    # binaries dynamically so upstream adding/removing a binary or arch doesn't
    # break the build, then mark whatever remains (agent-aix-ppc64) executable.
    cd server-nest/microservices/linux-go/bin; \
    rm -f -- *-amd64 *-arm64 *-ppc64le *-s390x *-arm; \
    find . -maxdepth 1 -type f -exec chmod +x {} +; \
    cd /opt/xormon-ng; \
    # post-upgrade.js copies otel-exporter-<arch> to otel-exporter at start-up,
    # so only the amd64 variant is needed (and scanned) here.
    rm -f -- server-nest/microservices/otel-exporter/bin/*-amd64 \
             server-nest/microservices/otel-exporter/bin/*-arm64 \
             server-nest/microservices/otel-exporter/bin/*-ppc64le \
             server-nest/microservices/otel-exporter/bin/*-s390x; \
    rm -rf server-nest/microservices/linux-go/simulator \
           server-nest/microservices/linux-go/go.mod \
           server-nest/microservices/linux-go/go.sum; \
    # TypeScript sources + type declarations + compiled tests (runtime uses dist/)
    find . -type f \( -name '*.ts' -o -name '*.tsbuildinfo' -o -name '*.spec.js' -o -name '*.test.js' \) -delete; \
    rm -rf server-nest/microservices/node/src; \
    # analyzer dev artifacts (notebooks, tests) - runtime keeps the .py services
    rm -rf server-nest/microservices/analyzer/tests; \
    find server-nest/microservices/analyzer -name '*.ipynb' -delete; \
    # drop the shipped static TLS keypair (a shared, publicly-known private
    # key). A unique self-signed cert is generated at startup instead, so no
    # private key is baked into the image.
    rm -f server-nest/ssl/xormon.key server-nest/ssl/xormon.crt

# Go binaries rebuilt in GOBUILD (see above)
COPY --from=GOBUILD --chmod=755 /out/linux-router /out/linux-service /out/agent /opt/xormon-ng/server-nest/microservices/linux-go/bin/
COPY --from=GOBUILD --chmod=755 /out/otel-exporter-amd64 /opt/xormon-ng/server-nest/microservices/otel-exporter/bin/

# Drop bundled devDependencies (typescript, jest, eslint, @nestjs/cli, ...);
# pm2 and all 61 runtime deps are kept. Needs registry access: npm 11 fetches
# packuments for entries it flags invalid (debug, ws, ...) even when they are
# already installed, so a --network=none prune fails with EAI_AGAIN. The tree is
# not modified by the fetches; --prefer-offline keeps them to the minimum.
RUN set -eux; \
    cd /opt/xormon-ng/server-nest; \
    npm prune --omit=dev --prefer-offline --no-audit --no-fund; \
    # package-lock.json is kept for now: the patch step below feeds it to
    # "bun audit" and removes it afterwards.
    # drop docs/changelogs from the remaining runtime packages (keep LICENSE)
    find node_modules -type f \( -iname '*.md' -o -iname '*.markdown' -o -iname 'CHANGELOG*' \) -delete; \
    # drop test/example/CI dirs shipped inside packages (never imported at runtime)
    find node_modules -type d \( -name test -o -name tests -o -name __tests__ \
       -o -name example -o -name examples -o -name .github -o -name coverage \) \
       -prune -exec rm -rf {} +

# glob 10/13 -> 14 (GHSA-3g3m-2fjr-6pw4, fixed only in 14), a major upgrade
# the in-major policy below does not make. typeorm calls glob.sync() only, which
# 14 keeps; rimraf moves to 14 itself from 6.1.4. typeorm's is done with an npm
# override, not a hand swap: npm re-resolves only that glob against
# package-lock.json and drops what it no longer needs, and --ignore-scripts
# keeps it from rebuilding the prebuilt native modules. The override applies
# only while typeorm still declares an older glob.
# vega/vega-functions stay on 5: vega 6 uses top-level await, so the app's
# require("vega") throws ERR_REQUIRE_ASYNC_MODULE (see README).
RUN set -eux; \
    cd /opt/xormon-ng/server-nest; \
    node -e ' \
        const fs = require("fs"); \
        const j = JSON.parse(fs.readFileSync("package.json", "utf8")); \
        const t = JSON.parse(fs.readFileSync("node_modules/typeorm/package.json", "utf8")); \
        const g = (t.dependencies || {}).glob; \
        if (g && Number(g.replace(/^[^0-9]*/, "").split(".")[0]) < 14) { \
            j.overrides = { ...j.overrides, typeorm: { ...(j.overrides || {}).typeorm, glob: "^14.0.6" } }; \
            fs.writeFileSync("package.json", JSON.stringify(j, null, 2) + "\n"); }'; \
    # The app's dataSource entity/subscriber/migration globs must find the same
    # files and classes with the new glob as with the old one.
    chk=' \
        const { importClassesFromDirectories: load } = require("./node_modules/typeorm/util/DirectoryExportedClassesLoader"); \
        const { glob } = require("./node_modules/typeorm/node_modules/glob"); \
        const d = process.cwd() + "/dist"; \
        (async () => { for (const p of [d + "/**/**.entity{.ts,.js}", d + "/**/*.subscriber{.ts,.js}", \
                                        d + "/**/*.migration{.ts,.js}", "dist/entity/**/*.entity.js"]) { \
            const f = glob.sync(p).sort(), c = await load({ log() {} }, [p]); \
            if (!f.length) throw new Error("no files for " + p); \
            console.log(p, f.length, c.length, f.join(",")); } })() \
            .catch(e => { console.error(e); process.exit(1); });'; \
    node -e "$chk" > /tmp/glob-before.txt; \
    npm install --omit=dev --ignore-scripts --prefer-offline --no-audit --no-fund; \
    # rimraf 6.1.4+ depends on glob 14, so an in-range update moves the
    # top-level glob 13 (rimraf's) to 14 the same way.
    npm update rimraf --omit=dev --ignore-scripts --prefer-offline --no-audit --no-fund; \
    echo "npm-major: rimraf $(node -p 'require("./node_modules/rimraf/package.json").version')"; \
    echo "npm-major: typeorm glob $(node -p 'require("./node_modules/typeorm/node_modules/glob/package.json").version')"; \
    node -e "$chk" > /tmp/glob-after.txt; \
    cmp /tmp/glob-before.txt /tmp/glob-after.txt; \
    rm -f /tmp/glob-before.txt /tmp/glob-after.txt; \
    rm -rf /root/.npm

# Patch vulnerable runtime npm packages. The upgrade list is generated at build
# time by "bun audit" instead of being maintained by hand, so new advisories are
# picked up on rebuild without editing this file.
#
# "bun audit fix --dry-run --json" reads package.json + package-lock.json only:
# it is read-only, writes no files and needs no node_modules, so the vendored
# tree is never re-resolved. That matters - a real "bun audit fix" (or npm audit
# fix) would reinstall, and this tarball ships prebuilt native modules (canvas,
# cpu-features, ssh2) that cannot be rebuilt in this stage; canvas fails node-gyp
# outright. Hence generate-then-patch rather than letting a package manager
# rewrite the tree.
#
# Policy is unchanged from the hand-maintained list this replaces: apply fixes
# that stay inside the same major (same major.minor for 0.x), as a caret range so
# npm still resolves the newest SemVer-compatible release. bun also reports fixes
# it declines because some dependent pins a tighter range ("blocked", e.g.
# engine.io wanting ws@~8.20.1); those are applied too when they stay within the
# major, which is what the manual list already did. Fixes needing a major bump are
# skipped and tracked in README: nodemailer, pm2, uuid 8, vega/vega-functions.
# The glob majors are made in the step above.
#
# Every copy of a package compatible with the resolved version (same major, or
# same major.minor for 0.x) is replaced in place anywhere in node_modules, with
# its bundled node_modules/ preserved; the rest of the tree is untouched. Runs
# after the prune above so npm sees the pristine vendored tree.
RUN --mount=type=bind,from=bun,source=/usr/local/bin/bun,target=/usr/bin/bun \
    set -eux; \
    cd /opt/xormon-ng/server-nest; \
    work=/tmp/npmpatch; \
    ckey() { case "$1" in 0.*) echo "$1" | cut -d. -f1-2;; *) echo "${1%%.*}";; esac; }; \
    # bun exits 1 whenever any advisory is left unfixed, which is the normal
    # state here (the major-bump exclusions above), so the status is ignored.
    # The parse below is the real guard: a network failure or a changed output
    # format yields unusable JSON and fails the build instead of silently
    # skipping every patch. The "migrated lockfile" notice goes to stderr, so
    # stdout is clean JSON.
    bun audit fix --dry-run --json 2>/dev/null > /tmp/audit.json || :; \
    node -e 'const a=JSON.parse(require("fs").readFileSync("/tmp/audit.json","utf8"));if(!Array.isArray(a.fixes)||!Array.isArray(a.blocked))throw new Error("unexpected bun audit output");const k=v=>v.startsWith("0.")?v.split(".").slice(0,2).join("."):v.split(".")[0];const s=new Set();for(const f of a.fixes)s.add(f.name+"@^"+f.to);for(const b of a.blocked)if(k(b.from)===k(b.to))s.add(b.name+"@^"+b.to);console.log([...s].sort().join("\n"))' > /tmp/specs.txt; \
    echo "npm-patch: bun audit proposes $(grep -c . /tmp/specs.txt || true) in-major upgrades"; \
    for spec in $(cat /tmp/specs.txt); do \
        name="${spec%@*}"; \
        # skip advisories against devDependencies the prune above already removed
        find node_modules -type d -path "*node_modules/$name" | grep -q . || continue; \
        rm -rf "$work"; mkdir -p "$work/x"; \
        npm pack "$spec" --pack-destination "$work" >/dev/null; \
        tar xzf "$work"/*.tgz -C "$work/x" --strip-components=1; \
        ver="$(node -pe "require('$work/x/package.json').version")"; \
        find node_modules -type d -path "*node_modules/$name" | while read -r d; do \
            inst="$(node -pe "require('./$d/package.json').version" 2>/dev/null)" || continue; \
            [ "$(ckey "$inst")" = "$(ckey "$ver")" ] || continue; \
            [ "$inst" = "$ver" ] && continue; \
            [ "$(printf '%s\n%s\n' "$inst" "$ver" | sort -V | head -n1)" = "$ver" ] && continue; \
            rm -rf "$work/nm"; \
            [ -d "$d/node_modules" ] && mv "$d/node_modules" "$work/nm"; \
            rm -rf "$d"; mkdir -p "$d"; cp -a "$work/x/." "$d/"; \
            [ -d "$work/nm" ] && mv "$work/nm" "$d/node_modules"; \
            echo "npm-patch: $d $inst -> $ver"; \
        done; \
    done; \
    rm -rf "$work" /tmp/audit.json /tmp/specs.txt; \
    rm -f package-lock.json; \
    # re-strip docs/tests that the freshly fetched packages re-introduce
    find node_modules -type f \( -iname '*.md' -o -iname '*.markdown' -o -iname 'CHANGELOG*' \) -delete; \
    find node_modules -type d \( -name test -o -name tests -o -name __tests__ \
       -o -name example -o -name examples -o -name .github -o -name coverage \) \
       -prune -exec rm -rf {} +

# Python venv for the analyzer microservice (prediction / anomaly detection).
# pip is kept - the analyzer runs `pip freeze` to self-check at runtime.
RUN python3 -m venv /opt/xormon-ng/server-nest/venv \
    && /opt/xormon-ng/server-nest/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/xormon-ng/server-nest/venv/bin/pip install --no-cache-dir \
       -r /opt/xormon-ng/server-nest/microservices/analyzer/requirements/requirements.txt \
    && find /opt/xormon-ng/server-nest/venv -type d -name tests -prune -exec rm -rf {} + \
    && find /opt/xormon-ng/server-nest/venv -depth -type d -name '__pycache__' -exec rm -rf {} +

# ---------------------------------------------------------------------------
# Stage 2: runtime
# ---------------------------------------------------------------------------
FROM ubuntu:26.10@sha256:1c2a84ae3f2a24aeb97cded5b41f0211b441662f1a188cbd2e139e7625f6f1d6

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/xormon-ng"
LABEL org.opencontainers.image.description="XorMon NG is a unified full-stack infrastructure performance and capacity monitoring tool"

ARG DEBIAN_FRONTEND=noninteractive

ENV NODE_ENV=production
ENV DOCKER=1
ENV PYTHONUNBUFFERED=1

# create file to see if this is the firstrun when started
RUN touch /firstrun

# runtime-only dependencies. dist-upgrade patches all base-image packages
# (libc6, libxml2, libgcrypt20, util-linux, ...) to the latest security
# releases - robust across rebuilds, no version pinning to go stale.
RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    tzdata \
    procps \
    iproute2 \
    iputils-ping \
    openssh-client \
    python3 \
    libgomp1 \
    libatomic1 \
    snmp \
    libsnmp-perl \
    sblim-wbemcli \
    libaio1t64 \
    perl \
    libtimedate-perl \
    libxml-simple-perl \
    libxml-sax-perl \
    libxml-libxml-perl \
    libxml-parser-perl \
    liblwp-protocol-https-perl \
    libwww-perl \
    libjson-perl \
    libjson-xs-perl \
    libdbi-perl \
    libdbd-pg-perl \
    libarchive-zip-perl \
    libtext-template-perl \
    libterm-readkey-perl \
    libuuid-perl \
    unixodbc \
    openssl \
    && rm -rf /var/lib/apt/lists/* \
       /usr/share/doc/* /usr/share/man/* /usr/share/locale/* \
       /var/cache/debconf/*-old /var/log/* \
    # pebble (Canonical's service manager) ships in the ubuntu base rootfs but
    # is unused here and unnecessary attack surface - remove it
       /usr/bin/pebble

# Node.js 24 runtime (+ npm) from the build stage
COPY --from=build /usr/local /usr/local

# setup default user
RUN groupadd xormon \
    && useradd -m -g xormon -s /bin/bash xormon

# expose ports for the web UI (HTTPS) and the agent/data receiver
EXPOSE 8443 8162

# pruned application (incl. node_modules, dist, perl-modules, mibs, venv)
COPY --from=build --chown=xormon:xormon /opt/xormon-ng /home/xormon/xormon-ng

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# persist only the data dir (upstream-accurate; avoids shadowing the app)
VOLUME [ "/home/xormon/xormon-ng/server-nest/files" ]

ENTRYPOINT [ "/startup.sh" ]
