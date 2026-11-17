FROM ghcr.io/jauderho/alpine:3.24.4@sha256:16766983b06e65d152c5dbfe98e4215c39f24d4564a2dd493722325851ee9dc0

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

