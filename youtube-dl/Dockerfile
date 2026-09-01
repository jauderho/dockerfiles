FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547

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
 && curl -Lo /usr/local/bin/youtube-dl --proto "=https" --proto-redir "=https" \
        https://github.com/ytdl-org/youtube-dl/releases/download/2021.12.17/youtube-dl \
 #&& curl -Lo /usr/local/bin/youtube-dl https://yt-dl.org/downloads/latest/youtube-dl \
 #&& curl -Lo youtube-dl.sig https://yt-dl.org/downloads/latest/youtube-dl.sig \
 #&& gpg --keyserver keyserver.ubuntu.com --recv-keys '7D33D762FD6C35130481347FDB4B54CBA4826A18' \
 #&& gpg --keyserver keyserver.ubuntu.com --recv-keys 'ED7F5BF46B3BBED81C87368E2C393E0F18A9236D' \
 #&& gpg --verify youtube-dl.sig /usr/local/bin/youtube-dl \
    # 0555: read+execute for everyone, write bit set for no one. Nothing
    # in the image updates it in place. root can still override this via
    # CAP_DAC_OVERRIDE, so it hardens against a non-root --user only.
 && chmod 0555 /usr/local/bin/youtube-dl \
    # Clean-up
 #&& rm youtube-dl.sig \
 && apk del curl gnupg \
    # Create directory to hold downloads.
 && mkdir /downloads \
    # 0750, not world-writable: root is the only account that writes
    # here. Running with --user needs a bind mount over /downloads to
    # keep anything, and then the host directory's permissions apply
    # instead of these - so nothing that survives a run needs o+w.
 && chmod 0750 /downloads \
    # Sets up cache.
 && mkdir /.cache \
    # Only consulted when HOME resolves to /, i.e. under --user. Left
    # root-owned: a missed cache is not fatal, yt-dlp just recomputes.
 && chmod 0750 /.cache

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

WORKDIR /downloads

VOLUME ["/downloads"]

# Basic check.
RUN dumb-init youtube-dl --version

ENTRYPOINT ["dumb-init", "youtube-dl"]
CMD ["--help"]
