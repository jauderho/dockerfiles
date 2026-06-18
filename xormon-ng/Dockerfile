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
    find server-nest/microservices/analyzer -name '*.ipynb' -delete

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

# runtime-only dependencies
RUN apt-get update \
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
