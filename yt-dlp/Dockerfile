FROM ghcr.io/jauderho/alpine:3.22.1@sha256:6cedbe16d634f856346fb6224aeddf939413076aaf08bc0216a2ee1759917a56

# https://github.com/Yelp/dumb-init/releases
ARG DUMB_INIT_VERSION=1.2.5

ARG BUILD_VERSION
#ARG ARCHIVE_URL=https://github.com/yt-dlp/yt-dlp/archive/

RUN set -x \
 && apk update \
 && apk upgrade -a \
 && apk add --no-cache \
        ca-certificates \
        curl \
        dumb-init \
        ffmpeg \
        python3 \
        py3-mutagen \
    # Install youtube-dl
 && curl -Lo /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/download/${BUILD_VERSION}/yt-dlp \
 #&& curl -Lo SHA2-256SUMS https://github.com/yt-dlp/yt-dlp/releases/download/${BUILD_VERSION}/SHA2-256SUMS \
 #&& cat SHA2-256SUMS | grep yt-dlp: | awk -F: '{print $2" "$1}' | sha256sum -c \
 && chmod a+rx /usr/local/bin/yt-dlp \
    # Clean-up
 #&& rm SHA2-256SUMS \
 && apk del curl \
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
