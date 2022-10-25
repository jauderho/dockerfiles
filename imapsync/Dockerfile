# Number of imapsync images pulled so far (2021_11_29): 608326
# Command used:
# curl -s https://hub.docker.com/v2/repositories/jauderho/imapsync/ | jq '.pull_count'

FROM ubuntu:22.10@sha256:4f9ec2c0aa321966bfe625bc485aa1d6e96549679cfdf98bb404dfcb8e141a7f

ARG BUILD_VERSION

RUN set -xe && \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  libauthen-ntlm-perl \
  libcgi-pm-perl \
  libcrypt-openssl-rsa-perl \
  libdata-uniqid-perl \
  libdigest-hmac-perl \
  libdist-checkconflicts-perl \
  libencode-imaputf7-perl \
  libfile-copy-recursive-perl \
  libfile-tail-perl \
  libio-compress-perl \
  libio-socket-ssl-perl \
  libio-socket-inet6-perl \
  libio-tee-perl \
  libhtml-parser-perl \
  libjson-webtoken-perl \
  libmail-imapclient-perl \
  libparse-recdescent-perl \
  libmodule-scandeps-perl \
  libpar-packer-perl \
  libreadonly-perl \
  libregexp-common-perl \
  libsys-meminfo-perl \
  libterm-readkey-perl \
  libunicode-string-perl \
  liburi-perl  \
  libwww-perl \
  wget \
  make \
  time \
  cpanminus \
  openssl \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && cd /usr/bin/ \
  && pwd \
  && wget -N https://imapsync.lamiral.info/imapsync \
        https://imapsync.lamiral.info/prerequisites_imapsync \
        https://raw.githubusercontent.com/google/gmail-oauth2-tools/master/python/oauth2.py \
  && chmod +x imapsync oauth2.py \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/imapsync"
LABEL org.opencontainers.image.description="Email IMAP tool for syncing, copying, migrating and archiving email mailboxes between servers"

WORKDIR /var/tmp/

# EXPOSE
ENV HOME /var/tmp/
STOPSIGNAL SIGINT
HEALTHCHECK NONE
USER nobody:nogroup

ENTRYPOINT ["/usr/bin/imapsync"]
CMD ["--help"]
