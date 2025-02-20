FROM ghcr.io/jauderho/alpine:3.21.3@sha256:8139b5dd95ef46202c45b611a4b7e972defda480df2e058b95b6a07b4f2e96c4

WORKDIR /home/ssh-audit

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jtesta/ssh-audit/archive/

RUN test -n "${BUILD_VERSION}" \
    && apk update \
    && apk upgrade -a \
    && build_pkgs="curl" \
    && runtime_pkgs="ca-certificates python3" \
    && apk add --no-cache --virtual build-dependencies ${build_pkgs} \
    && apk add --no-cache ${runtime_pkgs}  \
    && curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/ssh-audit.tar.gz \
    && tar xvzf /tmp/ssh-audit.tar.gz --strip 1 -C /home/ssh-audit \
    && addgroup ssh-audit \
    && adduser -G ssh-audit -g "ssh-audit user" -s /bin/bash -D ssh-audit \ 
    && apk del build-dependencies \
    && rm -rf /var/cache/apk/*

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/ssh-audit"
LABEL org.opencontainers.image.description="ssh-audit is a tool for ssh server & client configuration auditing"

EXPOSE 2222
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
USER nobody:nogroup

ENTRYPOINT ["python3", "./ssh-audit.py"]

