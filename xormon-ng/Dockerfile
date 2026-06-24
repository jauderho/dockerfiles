#!/usr/bin/docker build .
#
# VERSION               1.0

# ---------------------------------------------------------------------------
# Stage 1: build - download Node.js + the XorMon NG tarball, prune, build venv
# ---------------------------------------------------------------------------
FROM ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64 AS build

ARG BUILD_VERSION
ARG NODE_VERSION=24.15.0
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
RUN curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz \
    && tar xf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz \
    && rm -rf /usr/local/include /usr/local/CHANGELOG.md /usr/local/README.md \
       /usr/local/lib/node_modules/npm/docs /usr/local/lib/node_modules/npm/man \
    && node -v

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
    # keep only amd64 Go binaries (~78MB saved)
    cd server-nest/microservices/linux-go/bin; \
    mv agent-amd64 agent; \
    mv linux-service-amd64 linux-service; \
    rm -f agent-arm64 agent-ppc64le linux-service-arm64 linux-service-ppc64le; \
    chmod +x agent linux-service linux-router; \
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
    rm -f package-lock.json; \
    # drop docs/changelogs from the remaining runtime packages (keep LICENSE)
    find node_modules -type f \( -iname '*.md' -o -iname '*.markdown' -o -iname 'CHANGELOG*' \) -delete; \
    # drop test/example/CI dirs shipped inside packages (never imported at runtime)
    find node_modules -type d \( -name test -o -name tests -o -name __tests__ \
       -o -name example -o -name examples -o -name .github -o -name coverage \) \
       -prune -exec rm -rf {} +

# Patch vulnerable runtime npm packages. Each entry is a caret (^) range anchored
# at the version upstream ships, so npm resolves the newest SemVer-COMPATIBLE
# release at build time - patch/minor only, never a major bump (and caret locks
# the minor for 0.x packages). Using a range instead of a hard pin means future
# security releases are picked up automatically on rebuild without editing this
# list. Every copy of a package compatible with the resolved version (same major,
# or same major.minor for 0.x) is replaced in place anywhere in node_modules, with
# its bundled node_modules/ preserved; the rest of the tree is untouched. Runs
# after the prune above so npm sees the pristine vendored tree. Packages whose ONLY
# fix is a major bump are left alone and tracked in README: nodemailer, pm2, uuid 8.
RUN set -eux; \
    cd /opt/xormon-ng/server-nest; \
    work=/tmp/npmpatch; \
    ckey() { case "$1" in 0.*) echo "$1" | cut -d. -f1-2;; *) echo "${1%%.*}";; esac; }; \
    for spec in \
        @hono/node-server@^1.19.9 @isaacs/brace-expansion@^5.0.0 \
        @modelcontextprotocol/sdk@^1.25.2 @nestjs/core@^11.1.12 \
        ajv@^8.17.1 axios@^1.13.2 basic-ftp@^5.1.0 \
        brace-expansion@^1.1.12 brace-expansion@^2.0.2 diff@^4.0.2 \
        fast-uri@^3.1.0 fast-xml-parser@^5.3.6 file-type@^21.3.0 \
        follow-redirects@^1.15.11 form-data@^4.0.5 handlebars@^4.7.8 \
        hono@^4.11.4 ip-address@^10.1.0 joi@^18.0.2 js-yaml@^4.1.1 \
        lodash@^4.17.21 minimatch@^3.1.2 minimatch@^5.1.6 minimatch@^9.0.5 \
        minimatch@^10.1.1 multer@^2.0.2 path-to-regexp@^8.3.0 picomatch@^2.3.1 \
        qs@^6.14.1 socket.io-parser@^4.2.5 systeminformation@^5.30.5 tar@^7.5.4 \
        tmp@^0.2.5 typeorm@^0.3.28 uuid@^11.1.0 uuid@^13.0.0 vega@^5.31.0 \
        vega-expression@^5.1.2 vega-functions@^5.16.0 ws@^7.5.10 ws@^8.18.3 \
    ; do \
        name="${spec%@*}"; \
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
    rm -rf "$work"; \
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
FROM ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

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
       /var/cache/debconf/*-old /var/log/*

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
