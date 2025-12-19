FROM ghcr.io/jauderho/alpine:3.23.2@sha256:19acd40dbe98c0f031872056b0f568990c35334e4f90c1d772989255fc8d711b

# https://github.com/Yelp/dumb-init/releases
ARG DUMB_INIT_VERSION=1.2.5

ARG BUILD_VERSION
#ARG ARCHIVE_URL=https://github.com/yt-dlp/yt-dlp/archive/

RUN set -x \
 && apk update \
 && apk upgrade -a \
 && apk add --no-cache \
        ca-certificates \
        #deno \
        dumb-init \
        ffmpeg \
        python3 \
        py3-mutagen \
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
 && curl -Lo /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/download/${BUILD_VERSION}/yt-dlp \
 #&& curl -Lo SHA2-256SUMS https://github.com/yt-dlp/yt-dlp/releases/download/${BUILD_VERSION}/SHA2-256SUMS \
 #&& cat SHA2-256SUMS | grep yt-dlp: | awk -F: '{print $2" "$1}' | sha256sum -c \
 && chmod a+rx /usr/local/bin/yt-dlp \
 # Conditionally install curl_cffi only on supported arches
 && case "$(uname -m)" in \
       x86_64|aarch64) python3 -m pip install --no-cache-dir curl_cffi --break-system-packages ;; \
       *) echo "Skipping curl_cffi: unsupported arch $(uname -m)" ;; \
    esac \
    # Clean-up
 #&& rm SHA2-256SUMS \
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
