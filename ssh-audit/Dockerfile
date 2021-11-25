FROM alpine:3.15.0

WORKDIR /home/ssh-audit

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jtesta/ssh-audit/archive/

RUN test -n "${BUILD_VERSION}" \
    && apk update \
    #&& apk add --no-cache bash procps drill git coreutils libidn curl socat openssl xxd \
    && apk add --no-cache ca-certificates curl python3 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/ssh-audit.tar.gz \
    && tar xvzf /tmp/ssh-audit.tar.gz --strip 1 -C /home/ssh-audit \
    && addgroup ssh-audit \
    && adduser -G ssh-audit -g "ssh-audit user" -s /bin/bash -D ssh-audit 

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/ssh-audit"
LABEL org.opencontainers.image.description="ssh-audit is a tool for ssh server & client configuration auditing"

EXPOSE 2222
USER ssh-audit

ENTRYPOINT ["python3", "./ssh-audit.py"]

