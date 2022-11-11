FROM alpine:3.16.2@sha256:65a2763f593ae85fab3b5406dc9e80f744ec5b449f269b699b5efd37a07ad32e

# https://github.com/Yelp/dumb-init/releases
ARG DUMB_INIT_VERSION=1.2.5

ARG BUILD_VERSION
#ARG ARCHIVE_URL=https://github.com/yt-dlp/yt-dlp/archive/

RUN set -x \
 && apk update  \
 && apk add --no-cache \
        ca-certificates \
        curl \
        dumb-init \
        ffmpeg \
        python3 \
    # Install youtube-dl
 && curl -Lo /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/download/${BUILD_VERSION}/yt-dlp \
 #&& curl -Lo SHA2-256SUMS https://github.com/yt-dlp/yt-dlp/releases/download/${BUILD_VERSION}/SHA2-256SUMS \
 #&& cat SHA2-256SUMS | grep yt-dlp: | awk -F: '{print $2" "$1}' | sha256sum -c \
 && chmod a+rx /usr/local/bin/yt-dlp \
    # Requires python -> python3.
 && ln -s /usr/bin/python3 /usr/bin/python \
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
