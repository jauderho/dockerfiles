FROM ghcr.io/jauderho/alpine:3.24.1@sha256:fc6aa8bd54b01bbe7fd9e2d2e79c87837ab82abf83387a0dbb16fb6c7b17997d

# https://github.com/Yelp/dumb-init/releases
ARG DUMB_INIT_VERSION=1.2.5

ARG BUILD_VERSION
#ARG ARCHIVE_URL=https://github.com/yt-dlp/yt-dlp/archive/
ARG RELEASE_URL=https://github.com/yt-dlp/yt-dlp/releases/download/

RUN set -x \
 && apk update \
 && apk upgrade -a \
 && apk add --no-cache \
        ca-certificates \
        dumb-init \
        ffmpeg \
        python3 \
        py3-mutagen \
        py3-pycryptodomex \
        py3-pip \
        zstd \
        nghttp2 \        
 && apk add --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/community deno simdutf \
 && apk add --no-cache --virtual .build-deps \
        curl \
        build-base \
        gcc \
        make \
        python3-dev \
        zstd-dev \
        nghttp2-dev \
        libffi-dev \
 && cd /usr/local/bin \
 && curl -Lo yt-dlp ${RELEASE_URL}${BUILD_VERSION}/yt-dlp \
 && curl -Lo SHA2-256SUMS ${RELEASE_URL}${BUILD_VERSION}/SHA2-256SUMS \
 && cat SHA2-256SUMS | grep "yt-dlp$" | sha256sum -csw - \
 && chmod a+rx /usr/local/bin/yt-dlp \
 # Conditionally install curl_cffi only on supported arches
 && case "$(uname -m)" in \
       x86_64|aarch64) python3 -m pip install --no-cache-dir curl_cffi --break-system-packages ;; \
       *) echo "Skipping curl_cffi: unsupported arch $(uname -m)" ;; \
    esac \
 # Clean-up
 && rm SHA2-256SUMS \
 && apk del .build-deps \
 # Create directory to hold downloads.
 && mkdir /downloads \
 && chmod a+rw /downloads \
 # Sets up cache.
 && mkdir /.cache \
 && chmod 777 /.cache

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

WORKDIR /downloads

VOLUME ["/downloads"]

# Basic check.
RUN dumb-init yt-dlp --version

ENTRYPOINT ["dumb-init", "yt-dlp"]
CMD ["--help"]
