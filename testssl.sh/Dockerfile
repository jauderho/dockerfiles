FROM alpine:3.17.1@sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a

WORKDIR /home/testssl

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/drwetter/testssl.sh/archive/

RUN test -n "${BUILD_VERSION}" \
    && apk update \
    && apk upgrade -a \
    && apk add --no-cache bash procps drill coreutils libidn curl socat openssl xxd \
    && curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/testssl.tar.gz \
    && tar xzf /tmp/testssl.tar.gz --strip 1 -C /home/testssl \
    && addgroup testssl \
    && adduser -G testssl -g "testssl user" -s /bin/bash -D testssl \
    && ln -s /home/testssl/testssl.sh /usr/local/bin/ \
    && mkdir -m 755 -p /home/testssl/etc /home/testssl/bin

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/testssl.sh"
LABEL org.opencontainers.image.description="testssl.sh is a free command line tool which checks a server on any port for TLS/SSL ciphers"

USER testssl

ENTRYPOINT ["testssl.sh"]
CMD ["--help"]
