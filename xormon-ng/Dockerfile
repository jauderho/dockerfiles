#!/usr/bin/docker build .
#
# VERSION               1.0

# ---------------------------------------------------------------------------
# bun - build-time only. Supplies "bun audit", which generates the npm upgrade
# list further down. Bind-mounted into that one step rather than COPY, so the
# 80MB binary never lands in a layer (the runtime stage copies /usr/local
# wholesale, so anything installed there would ship).
# ---------------------------------------------------------------------------
FROM oven/bun:1.4.0@sha256:5ff609364c049b54eb0ff560ec96319729a972078ef2c755d758f0c6ef89c2d6 AS bun

# ---------------------------------------------------------------------------
# Stage 1: build - download Node.js + the XorMon NG tarball, prune, build venv
# ---------------------------------------------------------------------------
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b AS build

ARG BUILD_VERSION
ARG NODE_VERSION=24.19.0
# npm bundled with Node 24.19.0 (11.17.0) still vendors tar 7.5.16. npm 11.18.0+
# vendors tar 7.5.19, which carries the fix for GHSA-23hp-3jrh-7fpw.
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
    && rm -rf /var/lib/apt/lists/*

# Node.js 24 (glibc prebuilt) into /usr/local; drop C++ headers/docs (only
# needed to compile native addons, which we never do at runtime) - saves ~63MB
RUN curl -fsSL --proto "=https" --proto-redir "=https" \
        "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz \
    && tar xf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz \
    && npm install -g "npm@${NPM_VERSION}" --no-audit --no-fund \
    && rm -rf /usr/local/include /usr/local/CHANGELOG.md /usr/local/README.md \
       /usr/local/lib/node_modules/npm/docs /usr/local/lib/node_modules/npm/man \
    && node -v \
    && npm -v

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
    # keep only amd64 Go binaries (~78MB saved). Discover binaries dynamically
    # so upstream adding/removing a binary or arch doesn't break the build:
    # rename every *-amd64 to its base name, drop all other arch variants, then
    # mark whatever remains executable.
    cd server-nest/microservices/linux-go/bin; \
    for f in *-amd64; do [ -e "$f" ] && mv -f "$f" "${f%-amd64}"; done; \
    rm -f -- *-arm64 *-ppc64le *-s390x *-arm; \
    find . -maxdepth 1 -type f -exec chmod +x {} +; \
    cd /opt/xormon-ng; \
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

# Drop bundled devDependencies (typescript, jest, eslint, @nestjs/cli, ...);
# pm2 and all 61 runtime deps are kept. --network=none guarantees this is an
# offline, registry-free operation (fails the build otherwise).
RUN --network=none set -eux; \
    cd /opt/xormon-ng/server-nest; \
    npm prune --omit=dev --no-audit --no-fund; \
    # package-lock.json is kept for now: the patch step below feeds it to
    # "bun audit" and removes it afterwards.
    # drop docs/changelogs from the remaining runtime packages (keep LICENSE)
    find node_modules -type f \( -iname '*.md' -o -iname '*.markdown' -o -iname 'CHANGELOG*' \) -delete; \
    # drop test/example/CI dirs shipped inside packages (never imported at runtime)
    find node_modules -type d \( -name test -o -name tests -o -name __tests__ \
       -o -name example -o -name examples -o -name .github -o -name coverage \) \
       -prune -exec rm -rf {} +

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
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

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
    wget \
    tzdata \
    procps \
    net-tools \
    iproute2 \
    openssh-client \
    python3 \
    libgomp1 \
    libatomic1 \
    snmp \
    libsnmp-base \
    sblim-wbemcli \
    ldap-utils \
    libaio1t64 \
    perl \
    libtimedate-perl \
    libxml-simple-perl \
    libxml-sax-perl \
    libxml-libxml-perl \
    libcgi-pm-perl \
    liblwp-protocol-https-perl \
    libwww-perl \
    libio-tty-perl \
    libjson-perl \
    libjson-xs-perl \
    libnet-snmp-perl \
    libdbi-perl \
    libdbd-pg-perl \
    libdbd-odbc-perl \
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
