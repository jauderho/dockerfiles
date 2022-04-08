FROM alpine:3.15.4@sha256:315a3eab8ebf3bbcb931e34d13684b1e53186b8ec342c64383ce5c64890771ab

WORKDIR /home/ssh-audit

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jtesta/ssh-audit/archive/

RUN test -n "${BUILD_VERSION}" \
    && apk update \
    && build_pkgs="curl" \
    && runtime_pkgs="ca-certificates python3" \
    && apk add --no-cache --virtual build-dependencies ${build_pkgs} \
    && apk add --no-cache ${runtime_pkgs}  \
    && ln -s /usr/bin/python3 /usr/bin/python \
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
USER ssh-audit

ENTRYPOINT ["python3", "./ssh-audit.py"]

