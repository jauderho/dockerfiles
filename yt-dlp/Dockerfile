FROM ghcr.io/jauderho/alpine:3.22.0@sha256:bcec51c688c49175fe5ab5204735ec7051349ac0e52f115dd8505aa5d0558e74

# https://github.com/Yelp/dumb-init/releases
ARG DUMB_INIT_VERSION=1.2.5

ARG BUILD_VERSION
#ARG ARCHIVE_URL=https://github.com/yt-dlp/yt-dlp/archive/

# add pipx bin to path
ENV PATH=/root/.local/bin:$PATH
RUN echo 'export "PATH=$PATH:/root/.local/bin"' >> /etc/profile

RUN set -x \
   && apk update \
   && apk upgrade -a \
   && apk add --no-cache \
      # ca-certificates \
      # curl \
      dumb-init \
      ffmpeg \
      python3 \
      py3-mutagen \
      py3-pip \ 
      pipx \
   # Install youtube-dl
   && pipx install yt-dlp \
   && pipx inject yt-dlp yt-dlp-get-pot \
   # Create directory to hold downloads
   && mkdir /downloads \
   && chmod a+rw /downloads \
   # Sets up cache
   && mkdir /.cache \
   && chmod 777 /.cache

# ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

WORKDIR /downloads

VOLUME ["/downloads"]

# Basic check.
RUN dumb-init yt-dlp --version

ENTRYPOINT ["dumb-init", "yt-dlp"]
CMD ["--help"]
