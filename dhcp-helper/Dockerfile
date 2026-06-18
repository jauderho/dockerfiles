FROM ghcr.io/jauderho/alpine:3.24.1@sha256:c43ea832c5e5df2adadaec0a6487e5939c7080376ed831db9d422067519e86d8

ARG BUILD_VERSION

RUN apk update \
	&& apk upgrade -a \
    && apk --no-cache add dhcp-helper

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dhcp-helper"
LABEL org.opencontainers.image.description="dhcp-helper is a DHCP and BOOTP relay agent"

EXPOSE 67 67/udp
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

ENTRYPOINT ["dhcp-helper", "-n"]

