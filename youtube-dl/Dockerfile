FROM alpine:3.18.2@sha256:82d1e9d7ed48a7523bdebc18cf6290bdb97b82302a8a9c27d4fe885949ea94d1

# https://github.com/Yelp/dumb-init/releases
ARG DUMB_INIT_VERSION=1.2.5

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/ytdl-org/youtube-dl/archive/

RUN set -x \
 && apk update  \
 && apk upgrade -a \
 && apk add --no-cache \
        ca-certificates \
        curl \
        dumb-init \
        ffmpeg \
        gnupg \
        python3 \
    # Install youtube-dl
    # https://github.com/rg3/youtube-dl
 && curl -Lo /usr/local/bin/youtube-dl https://yt-dl.org/downloads/latest/youtube-dl \
 #&& curl -Lo youtube-dl.sig https://yt-dl.org/downloads/latest/youtube-dl.sig \
 #&& gpg --keyserver keyserver.ubuntu.com --recv-keys '7D33D762FD6C35130481347FDB4B54CBA4826A18' \
 #&& gpg --keyserver keyserver.ubuntu.com --recv-keys 'ED7F5BF46B3BBED81C87368E2C393E0F18A9236D' \
 #&& gpg --verify youtube-dl.sig /usr/local/bin/youtube-dl \
 && chmod a+rx /usr/local/bin/youtube-dl \
    # Clean-up
 #&& rm youtube-dl.sig \
 && apk del curl gnupg \
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
RUN dumb-init youtube-dl --version

ENTRYPOINT ["dumb-init", "youtube-dl"]
CMD ["--help"]
